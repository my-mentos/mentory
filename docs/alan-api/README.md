# Alan API 사용법

## 목차

- [Alan API 사용법](#alan-api-사용법)
  - [목차](#목차)
  - [API 테스트](#api-테스트)
  - [연동 가이드](#연동-가이드)
    - [REST 호출 빌더](#rest-호출-빌더)
    - [SSE 스트림 처리](#sse-스트림-처리)
    - [상태 초기화 요청](#상태-초기화-요청)
  - [키 관리](#키-관리)
    - [Secrets.xcconfig](#secretsxcconfig)
    - [xcconfig를 활용한 APIKey 관리](xcconfig-api-key.md)

## API 테스트

![set_variable](set_variable.png)

![question](question.png)

![sse_streaming](sse_streaming.png)

![reset_state](reset_state.png)

## 연동 가이드

### REST 호출 빌더

```swift
struct AlanQuestionResponse: Decodable {
    struct Action: Decodable {
        let name: String
        let speak: String
    }
    let action: Action?
    let content: String
}

func makeQuestionRequest(content: String, clientID: String) throws -> URLRequest {
    var components = URLComponents(string: AlanEnvironment.current.baseURL)!
    components.path = "/api/v1/question"
    components.queryItems = [
        .init(name: "content", value: content),
        .init(name: "client_id", value: clientID)
    ]

    guard let url = components.url else { throw AlanError.invalidURL }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(Secrets.alanAPIKey)", forHTTPHeaderField: "Authorization")
    return request
}
```

`AlanClient.sendQuestion(...)`는 위 요청을 만들어 `URLSession.data(for:)`를 호출한 뒤 `AlanQuestionResponse`로 디코드하여 도메인 모델(`LLMEmotionSummary`)에 매핑합니다.

### SSE 스트림 처리

```swift
func streamQuestion(content: String, clientID: String) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
        Task {
            do {
                let request = makeSSERequest(content: content, clientID: clientID)
                let (bytes, _) = try await URLSession.shared.bytes(for: request)
                for try await line in bytes.lines {
                    guard line.hasPrefix("data: ") else { continue }
                    let payload = line.dropFirst(6)
                    if let chunk = decodeSSEChunk(payload) {
                        continuation.yield(chunk)
                        if chunk.isComplete { break }
                    }
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
```

`decodeSSEChunk`는 `type == "continue"`일 때 `data.content`를, `type == "complete"`일 때 스트림 종료를 알리는 구조를 반환하도록 구현합니다(예: `AlanStreamChunk(text: String, isComplete: Bool)`).

### 상태 초기화 요청

```swift
struct ResetAgentStateRequest: Encodable { let client_id: String }

func resetState(clientID: String) async throws {
    var request = URLRequest(url: AlanEnvironment.current.url(path: "/api/v1/reset-state"))
    request.httpMethod = "DELETE"
    request.setValue("Bearer \(Secrets.alanAPIKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(ResetAgentStateRequest(client_id: clientID))

    let (_, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw AlanError.resetFailed
    }
}
```

초기화는 사용자가 계정을 로그아웃하거나 감정 히스토리를 삭제할 때 호출합니다. 호출 후 Mentory 내 캐시와 SwiftData 레코드도 함께 정리해야 합니다.

## 키 관리

> Alan API Key를 xcconfig로 전달하는 전체 예시는 [xcconfig를 활용한 APIKey 관리](xcconfig-api-key.md) 문서를 참고하세요.

### Secrets.xcconfig

1. 프로젝트 루트에 `Config/Secrets.xcconfig`를 만든 뒤 Xcode 프로젝트에 드래그합니다(“Copy items if needed” 체크).
2. 파일 안에 아래와 같이 키를 정의합니다. 값은 큰따옴표로 감싸 두는 편이 안전합니다.
   ```xcconfig
   ALAN_API_KEY = "sk-xxxx"
   ```
3. `Config/Secrets.xcconfig`와 개인별 오버라이드 파일(`*.xcconfig.local`)은 `.gitignore`에 추가하여 커밋되지 않도록 합니다.
4. Xcode ▸ `Project` ▸ `Info` ▸ `Configurations`에서 Debug/Release 모두 `Secrets.xcconfig`를 추가로 include 하거나, `#include "Config/Secrets.xcconfig"`를 기존 설정 파일 상단에 넣어 빌드 설정이 키를 읽을 수 있게 합니다.
5. 런타임에서는 `ProcessInfo.processInfo.environment["ALAN_API_KEY"]`를 통해 값을 읽고 `Secrets.alanAPIKey`와 같은 헬퍼로 감싼 뒤 `Authorization` 헤더에 설정합니다.
6. 로컬 개발자는 민감한 값을 `Config/Secrets.xcconfig.local` 등에 유지하고, 팀과 공유할 필요가 있으면 1Password/Envault 등의 시크릿 볼트를 사용합니다.
7. CI/CD 파이프라인은 `xcodebuild` 실행 전에 `export ALAN_API_KEY=...` 또는 `xcodebuild -xcconfig Config/ci.Secrets.xcconfig` 식으로 동일한 값을 주입하여 로컬과 동일한 경로로 전달합니다.

> 참고: `Secrets.xcconfig`에 새로운 키를 추가했다면, 해당 키를 참조하는 Swift 타입(`Secrets`)이나 Build Settings(`OTHER_SWIFT_FLAGS`, `USER_DEFINED` 등)에서도 동일한 키 이름을 사용해야 합니다.
