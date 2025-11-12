# SwiftUI에서 Combine 기반 MVVM 사용하기

## 목차

- [SwiftUI에서 Combine 기반 MVVM 사용하기](#swiftui에서-combine-기반-mvvm-사용하기)
  - [목차](#목차)
  - [개요](#개요)
    - [MVVM이란](#mvvm이란)
    - [Combine이란](#combine이란)
    - [Combine의 역할](#combine의-역할)
  - [설명](#설명)
    - [소스 코드 구조](#소스-코드-구조)
  - [예시](#예시)
    - [TicTacToe-Mac](#tictactoe-mac)
  - [참고 자료](#참고-자료)

## 개요

### MVVM이란

MVVM은 모바일 애플리케이션에서 자주 사용되는 아키텍처 방식입니다.

SwiftUI는 선언형 UI 프레임워크이기 때문에 상태 변화를 예측 가능하게 관리하는 패턴이 중요합니다. Combine 기반 MVVM을 사용하면 `ObservableObject`로 ViewModel을 정의하고 `@Published` 또는 `@StateObject`를 활용해 UI와 데이터 스트림을 연결할 수 있습니다.

SwiftUI에서는 View 프로토콜을 채택한 구조체가 View와 ViewModel을 구현하기 위해 사용할 수 있습니다.

![alt text](image.png)

### Combine이란

Combine은 WWDC19에서 SwiftUI와 함께 공개된 비동기 프레임워크입니다.

Combine은 이벤트 파이프라인을 구축하여 인스턴스 간의 비동기 통신을 구현하도록 도와줍니다.

### Combine의 역할

기본적으로, MVVM에서 View가 ViewModel의 프로퍼티 변화로 View를 업데이트하려면 이를 View로 전달할 수 있어야 합니다. 그래서 Apple에서는 Combine 프레임워크를 만들어 SwiftUI에서 View를 업데이트하기 위한 용도로 사용한 것입니다.

Combine을 사용할 때 주의할 점은 Combine이 동시성 환경에서 사용하도록 의도되지 않았다는 점입니다. 그래서

## 설명

### 소스 코드 구조

프로젝트에 포함된 소스 코드들은 Domain과 Representation 폴더로 구분하여 관리합니다.

## 예시

### TicTacToe-Mac

```swift
final class EmotionDiaryViewModel: ObservableObject {
    @Published var entries: [EmotionEntry] = []
    @Published var isLoading = false
    private let repository: EmotionDiaryRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: EmotionDiaryRepository) {
        self.repository = repository
    }

    func load() {
        isLoading = true
        repository.fetchLatestEntries()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Load failed: \(error)")
                    }
                },
                receiveValue: { [weak self] entries in
                    self?.entries = entries
                }
            )
            .store(in: &cancellables)
    }
}
```

```swift
struct EmotionDiaryView: View {
    @StateObject private var viewModel: EmotionDiaryViewModel

    init(viewModel: EmotionDiaryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.entries) { entry in
            Text(entry.summary)
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .task { viewModel.load() }
    }
}
```

## 참고 자료

- [Apple: Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722/)
- [Apple: Data Essentials in SwiftUI](https://developer.apple.com/videos/play/wwdc2020/10040/)
- [Apple: Data Flow Through SwiftUI (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10019/)
