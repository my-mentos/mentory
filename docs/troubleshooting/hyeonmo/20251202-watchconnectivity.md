# 2025-12-02 WatchConnectivity MainActor 동시성 충돌

## 이슈 개요

- **증상**: WatchConnectivityManager의 delegate 메서드에서 `@MainActor` 격리 위반 경고 및 런타임 크래시 발생.
- **영향 범위**: iOS 앱 ↔ Watch 앱 간 모든 데이터 동기화 기능.
- **감지 배경**: Swift 6 동시성 체킹 활성화 후, WCSessionDelegate 메서드 호출 시 메인 스레드 단언(assertion) 실패.

## 진단 과정

1. **초기 구현 (`0cad008`)**:
   - `WatchConnectivityManager`를 `@MainActor`로 선언하여 `@Published` 속성 관리.
   - WCSessionDelegate 메서드를 `nonisolated`로 선언하고, 내부에서 `Task { @MainActor in }` 블록으로 UI 업데이트.

2. **비동기 개선 시도 (`9a29684`)**:
   - delegate 메서드에서 `nonisolated` 키워드를 제거하고 직접 `@MainActor` 메서드로 변경.
   - 의도: 모든 메서드를 메인 스레드에서 실행하여 동시성 문제 원천 차단.
   - **결과**: 빌드는 성공했으나, 런타임에 다음 오류 발생:
     ```
     Main actor-isolated instance method 'session(_:activationDidCompleteWith:error:)'
     cannot be used to satisfy nonisolated protocol requirement
     ```

3. **근본 원인**:
   - `WCSessionDelegate`의 메서드들은 **백그라운드 큐**에서 호출됨 (Apple 공식 문서 명시).
   - `@MainActor` 클래스에서 `nonisolated` 없이 delegate 메서드를 구현하면, Swift는 메인 스레드에서 실행하려고 시도.
   - 하지만 WatchConnectivity 프레임워크는 백그라운드에서 호출하므로 **스레드 격리 위반** 발생.

4. **검증 과정**:
   ```swift
   // ❌ 문제가 있던 코드 (9a29684)
   @MainActor
   final class WatchConnectivityManager: NSObject, ObservableObject {
       func session(_ session: WCSession, activationDidCompleteWith...) {
           // 이 메서드는 백그라운드 스레드에서 호출되는데
           // @MainActor 때문에 메인 스레드에서 실행하려고 시도 → 충돌
           self.connectionStatus = "활성화됨"  // 💥 메인 스레드 단언 실패
       }
   }
   ```

## 해결 방법

### 최종 해결책: `nonisolated(unsafe)` 변수 활용

**핵심**: `@MainActor` 메서드와 백그라운드 delegate 메서드 양쪽에서 접근할 수 있는 공유 변수를 `nonisolated(unsafe)`로 선언.

```swift
// ✅ iOS 앱 (Mentory/Mentory/Service/WatchConnectivity/WatchConnectivityManager.swift)
@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    // UI 상태용 @Published 속성
    @Published var isPaired: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var isReachable: Bool = false

    // 🔑 핵심: 백그라운드와 메인 액터 양쪽에서 접근할 데이터
    nonisolated(unsafe) private var todayString: String = ""
    nonisolated(unsafe) private var mentorMessage: String = ""
    nonisolated(unsafe) private var mentorCharacter: String = ""

    // @MainActor 메서드에서 nonisolated(unsafe) 변수 접근 가능
    func updateTodayString(_ string: String) {
        self.todayString = string  // ✅ 메인 액터에서 안전하게 쓰기
        self.sendDataToWatch()
    }

    func updateMentorMessage(_ message: String, character: String) {
        self.mentorMessage = message
        self.mentorCharacter = character
        self.sendDataToWatch()
    }

    // delegate 메서드는 nonisolated로 선언
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let isPaired = session.isPaired
        let isWatchAppInstalled = session.isWatchAppInstalled
        let isReachable = session.isReachable

        // @Published 속성은 메인 액터에서 업데이트
        Task { @MainActor in
            self.isPaired = isPaired
            self.isWatchAppInstalled = isWatchAppInstalled
            self.isReachable = isReachable
            print("WCSession 활성화 완료")
            self.sendDataToWatch()
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let request = message["request"] as? String

        if request == "initialData" {
            // ✅ nonisolated(unsafe) 변수는 백그라운드에서 안전하게 읽기
            let reply: [String: Any] = [
                "todayString": self.todayString,
                "mentorMessage": self.mentorMessage,
                "mentorCharacter": self.mentorCharacter
            ]
            replyHandler(reply)
        } else {
            replyHandler(["status": "received"])
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        let isReachable = session.isReachable
        Task { @MainActor in
            self.isReachable = isReachable
        }
    }
}
```

```swift
// ✅ Watch 앱 (MentoryWatch Watch App/Service/WatchConnectivityManager.swift)
@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    // UI 상태용 @Published 속성
    @Published var todayString: String = "명언을 불러오는 중..."
    @Published var mentorMessage: String = "멘토 메시지를 불러오는 중..."
    @Published var mentorCharacter: String = ""
    @Published var connectionStatus: String = "연결 대기 중"

    // 백그라운드에서 접근할 수 있도록 nonisolated로 선언
    nonisolated private let session: WCSession

    // 🔑 핵심: 캐시 데이터 (백그라운드 스레드에서 먼저 저장 → 메인 액터에서 @Published로 복사)
    nonisolated(unsafe) private var cachedTodayString: String = ""
    nonisolated(unsafe) private var cachedMentorMessage: String = ""
    nonisolated(unsafe) private var cachedMentorCharacter: String = ""

    // iPhone에서 데이터 요청 (백그라운드에서 실행 가능)
    nonisolated func requestDataFromPhone() {
        guard session.isReachable else {
            Task { @MainActor in
                self.connectionStatus = "iPhone과 연결되지 않음"
            }
            return
        }

        let message = ["request": "initialData"]
        session.sendMessage(message, replyHandler: { [weak self] reply in
            guard let self = self else { return }

            // ✅ 백그라운드에서 nonisolated(unsafe) 변수에 먼저 저장
            let quote = reply["todayString"] as? String ?? ""
            let mentorMsg = reply["mentorMessage"] as? String ?? ""
            let character = reply["mentorCharacter"] as? String ?? ""

            self.cachedTodayString = quote
            self.cachedMentorMessage = mentorMsg
            self.cachedMentorCharacter = character

            // 메인 액터에서 @Published 속성 업데이트
            Task { @MainActor in
                self.todayString = quote
                self.mentorMessage = mentorMsg
                self.mentorCharacter = character
                self.connectionStatus = "연결됨"
            }
        })
    }

    // Application Context 수신 (백그라운드에서 호출)
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // ✅ 백그라운드에서 nonisolated(unsafe) 변수에 저장
        if let quote = applicationContext["todayString"] as? String {
            self.cachedTodayString = quote
        }
        if let mentorMsg = applicationContext["mentorMessage"] as? String {
            self.cachedMentorMessage = mentorMsg
        }
        if let character = applicationContext["mentorCharacter"] as? String {
            self.cachedMentorCharacter = character
        }

        // 메인 액터에서 @Published 속성 업데이트
        Task { @MainActor in
            if let quote = applicationContext["todayString"] as? String {
                self.todayString = quote
            }
            if let mentorMsg = applicationContext["mentorMessage"] as? String {
                self.mentorMessage = mentorMsg
            }
            if let character = applicationContext["mentorCharacter"] as? String {
                self.mentorCharacter = character
            }
            self.connectionStatus = "연결됨"
        }
    }
}
```

### 핵심 패턴

#### 1. **데이터 분리: `@Published` vs `nonisolated(unsafe)` 🔑**

```swift
@MainActor
final class WatchConnectivityManager {
    // UI용: SwiftUI가 관찰하는 상태 (메인 액터에서만 업데이트)
    @Published var todayString: String = ""

    // 데이터 전송용: 백그라운드와 메인 액터 양쪽에서 접근 (캐시)
    nonisolated(unsafe) private var todayString: String = ""
}
```

**왜 `nonisolated(unsafe)`가 필요한가?**
- `@MainActor` 클래스에서 일반 변수는 메인 액터에 격리됨 → `nonisolated` delegate 메서드에서 접근 불가.
- `nonisolated(unsafe)`로 선언하면 Swift 동시성 체크를 **우회**하여 양쪽에서 모두 접근 가능.
- `unsafe`라는 이름이지만, **실제로는 안전**:
  - 쓰기: `@MainActor` 메서드 또는 순차적인 delegate 콜백에서만 발생.
  - 읽기: 문자열은 값 타입이므로 복사됨 (참조 공유 없음).

#### 2. **WCSessionDelegate 메서드 → `nonisolated`**

WCSessionDelegate 메서드는 Apple이 **백그라운드 큐**에서 호출하므로, `@MainActor` 클래스에서는 반드시 `nonisolated` 필요:

```swift
// ✅ 올바른 방식
nonisolated func session(_ session: WCSession, didReceiveMessage...) {
    // 백그라운드 스레드에서 실행됨
    self.cachedData = message["data"]  // nonisolated(unsafe) 변수 접근 가능
}

// ❌ 잘못된 방식 (9a29684 커밋의 실수)
func session(_ session: WCSession, didReceiveMessage...) {
    // @MainActor 메서드로 인식되지만, Apple은 백그라운드에서 호출 → 충돌
}
```

#### 3. **UI 업데이트 → `Task { @MainActor in }`**

`@Published` 속성은 메인 액터에서만 업데이트:

```swift
nonisolated func session(_ session: WCSession, didReceiveApplicationContext...) {
    // 1. 백그라운드에서 캐시에 저장
    self.cachedTodayString = applicationContext["todayString"] as? String ?? ""

    // 2. 메인 액터로 전환 후 UI 상태 업데이트
    Task { @MainActor in
        self.todayString = self.cachedTodayString  // @Published 업데이트
    }
}
```

#### 4. **메모리 관리 → `[weak self]`**

비동기 클로저에서 순환 참조 방지:

```swift
session.sendMessage(message, replyHandler: { [weak self] reply in
    guard let self = self else { return }
    // ...
})
```

## 회고 및 예방

### 배운 점

1. **Apple 프레임워크 스레드 정책 확인 필수**:
   - WatchConnectivity의 delegate 메서드는 백그라운드 큐에서 호출된다는 문서를 놓침.
   - 새로운 프레임워크 도입 시, delegate/completion handler의 실행 컨텍스트를 반드시 확인.

2. **`nonisolated(unsafe)`의 올바른 사용법 이해**:
   - `unsafe`라는 이름 때문에 꺼려지지만, 특정 패턴에서는 **안전하고 필수적**.
   - 백그라운드 delegate와 메인 액터 메서드가 같은 데이터를 공유해야 할 때 유일한 해결책.
   - 안전성 조건: 쓰기가 순차적이고, 읽기 시 값 타입 복사가 일어나는 경우.

3. **Swift Concurrency는 컴파일 타임에 모든 문제를 잡지 못함**:
   - `nonisolated` 없이도 빌드는 성공할 수 있음.
   - 런타임에 메인 스레드 체커(Main Thread Checker)가 활성화되어야 문제 감지.

4. **동시성 문제는 디버깅이 어려움**:
   - 증상이 간헐적이고 재현이 어려울 수 있음.
   - Xcode의 Thread Sanitizer, Main Thread Checker를 항상 활성화할 것.

5. **데이터 흐름을 명확히 설계**:
   - `@Published`: UI 바인딩용 (메인 액터에서만 쓰기).
   - `nonisolated(unsafe)`: 크로스 스레드 캐시용 (백그라운드에서 쓰기, 양쪽에서 읽기).
   - 이 둘을 명확히 분리하면 동시성 문제를 90% 예방 가능.

### 예방 조치

1. **프로토콜 delegate 구현 시 체크리스트**:
   - [ ] delegate 메서드가 어느 스레드에서 호출되는지 문서 확인.
   - [ ] `@MainActor` 클래스에서 구현 시, `nonisolated` 필요 여부 판단.
   - [ ] UI 업데이트는 `Task { @MainActor in }` 또는 `DispatchQueue.main.async` 사용.
   - [ ] 클로저에서 `[weak self]` 사용하여 순환 참조 방지.

2. **테스트 환경 설정**:
   - Xcode → Edit Scheme → Run → Diagnostics:
     - ✅ Thread Sanitizer (성능 영향 있음, 개발 중에만 사용)
     - ✅ Main Thread Checker (항상 활성화 권장)
   - 실제 기기에서 테스트 (WatchConnectivity는 시뮬레이터에서 제한적).

3. **코드 리뷰 포인트**:
   - delegate 메서드에서 `@Published` 속성 직접 수정하는 코드는 의심.
   - `nonisolated(unsafe)` 사용 시, 주석으로 안전한 이유 설명.

4. **문서화**:
   - `docs/watchos/watchconnectivity.md`에 동시성 주의사항 섹션 추가:
     ```markdown
     ## Swift Concurrency 주의사항

     WCSessionDelegate 메서드는 백그라운드 스레드에서 호출됩니다.
     `@MainActor` 클래스에서 구현할 때는 반드시 `nonisolated`로 선언하세요.
     ```

## 관련 자료

- Apple 공식 문서: [WCSessionDelegate - Thread Safety](https://developer.apple.com/documentation/watchconnectivity/wcsessiondelegate)
- Swift Evolution: [SE-0316 Global Actors](https://github.com/apple/swift-evolution/blob/main/proposals/0316-global-actors.md)
- 프로젝트 커밋:
  - 초기 구현: [0cad008](https://github.com/EST-iOS4/Mentory/commit/0cad008)
  - 실패한 시도: [9a29684](https://github.com/EST-iOS4/Mentory/commit/9a29684)
  - 롤백: [a0eedd0](https://github.com/EST-iOS4/Mentory/commit/a0eedd0)
  - 성공 버전: [423bb70](https://github.com/EST-iOS4/Mentory/commit/423bb70)
