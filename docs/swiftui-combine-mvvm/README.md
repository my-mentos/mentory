# SwiftUI에서 Combine 기반 MVVM 사용하기

## 목차

- [SwiftUI에서 Combine 기반 MVVM 사용하기](#swiftui에서-combine-기반-mvvm-사용하기)
  - [목차](#목차)
  - [개요](#개요)
    - [아키텍처 소개](#아키텍처-소개)
    - [파일 구조](#파일-구조)
  - [예시](#예시)
    - [상태 업데이트](#상태-업데이트)
    - [SampleCounter 둘러보기](#samplecounter-둘러보기)
    - [Publisher 예시 코드](#publisher-예시-코드)
  - [참고 자료](#참고-자료)

## 개요

### 아키텍처 소개

Mentory-iOS에서 사용한 아키텍처는 **MVVM**입니다. 프로젝트의 소스 코드는 Domain과 Presentation으로 구분되며, Domain은 비즈니스 로직과 데이터 상태를 관리하는 핵심 영역으로, 앱의 기능적 규칙과 모델을 정의합니다. 반면 Presentation은 사용자 인터페이스와 상호작용을 담당하며, SwiftUI를 통해 ViewModel로부터 전달받은 상태 변화를 즉각적으로 반영합니다.

![MVVM 구조 다이어그램](image.png)

### 파일 구조

아래는 프로젝트에서 사용하는 디렉토리 구조입니다. 애플리케이션의 상태와 관련된 모든 로직은 **Domain** 디렉토리 내에 정의되며, 여기서는 데이터 모델과 비즈니스 규칙, 그리고 상태 변화 로직이 관리됩니다. 반면 **Presentation** 디렉토리는 SwiftUI 기반의 사용자 인터페이스를 담당하며, ViewModel을 통해 전달된 상태 변화를 즉각적으로 반영하는 역할을 합니다.

```bash
# 프로젝트 폴더 구조
SampleCounter
├─ Domain            // 비즈니스 로직과 상태 객체
│  └─ SampleCounter  // 트리 형태고 구조화되는 객체들
└─ Presentation      // SwiftUI View와 App 진입점
   ├─ Graphic        // ContentView, SignInFormView 등 UI 조립
   └─ SampleCounterApp.swift
```

## 예시

### 상태 업데이트

예를 들어, 정해진 코드를 입력해야 사용할 수 있는 Counter 애플리케이션을 개발한다고 가정하면, 아래와 같이 폴더가 구성될 수 있습니다.

### SampleCounter 둘러보기

`docs/swiftui-combine-mvvm/SampleCounter/SampleCounter/Domain/SampleCounter.swift`에는 전역 상태를 보유하는 루트 객체가 정의되어 있습니다. 로그인 폼과 새로운 카운터를 동적으로 생성/소멸 시키며, 모든 속성이 `@Published`이기 때문에 다른 View가 쉽게 구독할 수 있습니다.

```swift
final class SampleCounter: ObservableObject {
    @Published var signInForm: SignInForm? = nil
    @Published var newCounter: NewCounter? = nil
    @Published var isSigned: Bool = false
    @Published var number: Int = 0

    func increment() { number += 1 }
    func decrement() { number -= 1 }

    func setUpForm() {
        guard signInForm == nil else { return }
        signInForm = SignInForm(owner: self)
    }
}
```

`SignInForm`과 `SignUpForm`(각각 `Domain/SampleCounter/SignInForm/` 폴더)은 소유자를 `nonisolated let owner`로 유지하면서 필요 시 상위 객체 상태를 갱신합니다. SwiftUI View는 아래와 같이 단순하게 상태를 관찰합니다.

```swift
struct ContentView: View {
    @ObservedObject var app: SampleCounter

    var body: some View {
        VStack {
            Text("숫자 : \(app.number)")
            Button("+") { app.increment() }
            Button("SetUp") { app.setUpForm() }
            if let form = app.signInForm {
                NavigationLink { SignInFormView(form) } label: {
                    Text("로그인으로 넘어갑니다.")
                }
            }
        }
    }
}
```

복잡한 화면에서는 `@StateObject`를 사용해 ViewModel 수명을 View와 일치시키거나, 전역 상태(예: `SampleCounter`)를 `@EnvironmentObject`로 주입해 전역적으로 구독할 수 있습니다.

### Publisher 예시 코드

아래 예시는 Mentory 앱의 감정 다이어리 화면을 모델링한 Combine 기반 ViewModel 샘플입니다. Repository에서 최신 기록을 전달받아 UI 상태를 갱신하는 기본 패턴을 보여줍니다.

이 패턴을 Mentory의 다른 화면에도 동일하게 적용할 수 있습니다. 주요 포인트는 **Publisher 체인을 ViewModel 내부에 숨기고**, View는 `@StateObject`/`@ObservedObject` 바인딩만 다루도록 만드는 것입니다.

## 참고 자료

- [Apple: Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722/)
- [Apple: Data Essentials in SwiftUI](https://developer.apple.com/videos/play/wwdc2020/10040/)
- [Apple: Data Flow Through SwiftUI (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10019/)
- [Apple: Combine in Practice](https://developer.apple.com/videos/play/wwdc2020/10147/)
