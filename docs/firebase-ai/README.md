# Firebase AI 사용하기

Firebase AI는 Google의 Gemini 모델을 Firebase 프로젝트에서 쉽게 사용할 수 있게 해주는 SDK입니다. 이 문서에서는 Mentory 프로젝트에서 Firebase AI를 사용하는 방법을 설명합니다.

## 목차
1. [Firebase AI란?](#firebase-ai란)
2. [프로젝트 설정](#프로젝트-설정)
3. [Firebase 초기화](#firebase-초기화)
4. [Gemini 모델 사용하기](#gemini-모델-사용하기)
5. [실전 예제](#실전-예제)

---

## Firebase AI란?

Firebase AI는 Firebase의 생성형 AI 기능으로, Google의 최신 Gemini 모델을 앱에 통합할 수 있습니다.

**주요 특징:**
- Gemini 2.5 Flash Lite 등 다양한 모델 지원
- 간단한 API로 텍스트 생성
- Firebase 콘솔에서 사용량 모니터링
- Google AI 백엔드 활용

---

## 프로젝트 설정

### 1. Swift Package Manager로 Firebase SDK 추가

Xcode 프로젝트에서 Firebase iOS SDK를 추가합니다:

**Package URL:**
```
https://github.com/firebase/firebase-ios-sdk.git
```

**필요한 패키지:**
- `FirebaseAI` - AI 기능을 위한 메인 SDK
- `FirebaseAILogic` - AI 로직 처리
- `FirebaseCore` - Firebase 핵심 기능

**Xcode에서 추가하는 방법:**
1. 프로젝트 Navigator에서 프로젝트 파일 선택
2. `Package Dependencies` 탭 선택
3. `+` 버튼 클릭
4. 위 URL 입력 및 버전 선택 (최소 12.6.0)
5. 필요한 패키지 선택

### 2. GoogleService-Info.plist 추가

Firebase 콘솔에서 다운로드한 `GoogleService-Info.plist` 파일을 프로젝트 루트에 추가합니다:

```
Mentory/
  ├── GoogleService-Info.plist  ← 이 위치에 추가
  ├── Mentory/
  └── ...
```

**Firebase 콘솔에서 파일 다운로드:**
1. [Firebase Console](https://console.firebase.google.com) 접속
2. 프로젝트 선택
3. 프로젝트 설정 > 일반
4. iOS 앱에서 `GoogleService-Info.plist` 다운로드

---

## Firebase 초기화

Firebase를 사용하기 전에 초기화가 필요합니다.

### App 진입점에서 초기화 (권장)

```swift
import SwiftUI
import FirebaseCore

@main
struct MentoryApp: App {
    init() {
        // Firebase 초기화
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### View에서 초기화 (테스트/프리뷰용)

```swift
init() {
    // 이미 초기화되었는지 확인
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
}
```

---

## Gemini 모델 사용하기

### 기본 사용법

```swift
import FirebaseAI

// 1. 모델 인스턴스 생성
let model = FirebaseAI
    .firebaseAI(backend: .googleAI())
    .generativeModel(modelName: "gemini-2.5-flash-lite")

// 2. 텍스트 생성 (비동기)
Task {
    do {
        let response = try await model.generateContent("안녕하세요!")
        if let text = response.text {
            print(text)
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### 사용 가능한 모델

```swift
// Gemini 2.5 Flash Lite (빠르고 가벼움)
.generativeModel(modelName: "gemini-2.5-flash-lite")

// Gemini Pro (더 강력한 모델)
.generativeModel(modelName: "gemini-pro")
```

### 백엔드 옵션

```swift
// Google AI 백엔드 (기본)
.firebaseAI(backend: .googleAI())

// Vertex AI 백엔드 (엔터프라이즈)
.firebaseAI(backend: .vertexAI())
```

---

## 실전 예제

프로젝트의 [GeminiView.swift](../../Mentory/Mentory/Presentation/Test/GeminiView.swift)에서 실제 사용 예제를 확인할 수 있습니다.

### 완전한 SwiftUI 예제

```swift
import SwiftUI
import FirebaseCore
import FirebaseAI

struct GeminiView: View {
    @State private var prompt: String = ""
    @State private var result: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    // Firebase AI 모델 인스턴스
    private let model: GenerativeModel

    init() {
        // Firebase 초기화
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // 모델 생성
        self.model = FirebaseAI
            .firebaseAI(backend: .googleAI())
            .generativeModel(modelName: "gemini-2.5-flash-lite")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Gemini 2.5-flash-lite Demo")
                    .font(.title2.bold())

                // 입력 필드
                TextField("프롬프트를 입력하세요…", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 8)

                // 생성 버튼
                Button(action: generateResponse) {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("생성하기")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.blue.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(prompt.isEmpty || isLoading)

                // 에러 메시지
                if let error = errorMessage {
                    Text("⚠️ 오류: \(error)")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                // 결과 표시
                ScrollView {
                    Text(result)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .navigationTitle("Gemini 테스트")
        }
    }

    // MARK: - Generate with Gemini
    @MainActor
    private func generateResponse() {
        guard !prompt.isEmpty else { return }

        isLoading = true
        result = ""
        errorMessage = nil

        Task {
            do {
                let response = try await model.generateContent(prompt)
                if let text = response.text {
                    self.result = text
                } else {
                    self.result = "결과 없음"
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}

#Preview {
    GeminiView()
}
```

### 주요 포인트

1. **@MainActor 사용**: UI 업데이트를 메인 스레드에서 실행
2. **Task 사용**: 비동기 작업을 위한 Swift Concurrency
3. **에러 핸들링**: try-catch로 안전하게 처리
4. **로딩 상태 관리**: @State로 UI 상태 추적

---

## 문제 해결

### Firebase가 초기화되지 않는 경우

```swift
// 에러: "Firebase app not initialized"
// 해결: init()에서 Firebase.configure() 호출 확인

if FirebaseApp.app() == nil {
    FirebaseApp.configure()
}
```

### GoogleService-Info.plist를 찾을 수 없는 경우

1. 파일이 프로젝트에 추가되었는지 확인
2. Target Membership이 올바른지 확인
3. Copy Bundle Resources에 포함되었는지 확인

### API 사용량 제한

Firebase 콘솔에서 사용량을 모니터링하고 필요시 할당량을 조정하세요.

---

## 참고 자료

- [Firebase AI 공식 문서](https://firebase.google.com/docs/ai)
- [Gemini API 문서](https://ai.google.dev/gemini-api/docs)
- [Firebase iOS SDK GitHub](https://github.com/firebase/firebase-ios-sdk)
- [프로젝트 예제 코드](../../Mentory/Mentory/Presentation/Test/GeminiView.swift)

---

**작성일**: 2025-11-20
**업데이트**: Firebase iOS SDK 12.6.0 기준
