# MindAnalyze API 호출 시 결과 미반환

## 현상
- MindAnalyze에서 감정 분석 API를 호출해도 콜백에 결과가 전달되지 않음
- 화면에서는 로딩 상태만 유지되어 사용자가 피드백을 받을 수 없음

## 영향
- MindAnalyzer가 API 응답을 그릴 수 없어 분석 리포트 작성이 불가
- 작성 중이던 `RecordForm` 데이터가 초기화되어 회복 불가한 데이터 손실이 발생

## 원인
`RecordForm`을 생성할 때 MindAnalyzer가 참조하는 동일 인스턴스를 사용한다. 그런데 폼 제출 직전에 폼을 초기화하도록 해두어 MindAnalyzer에 전달된 인스턴스 또한 초기화되었다.

```swift
// RecordForm.submit()
self.titleInput = ""
self.textInput = ""
self.imageInput = nil
self.voiceInput = nil
self.validationResult = .none
```

그 결과 MindAnalyzer는 분석 요청 직전에 비어있는 `RecordForm`을 전달받아 API 응답을 매핑할 수 없었고, 응답 처리가 중단되면서 "결과 미반환" 상태가 발생했다.
<img width="400" height="auto" alt="Simulator Screenshot - iPhone 17 Pro - 2025-11-19 at 14 31 31" src="https://github.com/user-attachments/assets/558dd327-29e5-41ec-8f85-8aadb0c9f96c" />

## 해결
1. 폼 초기화가 필요한 경우 MindAnalyzer가 사용을 마친 뒤 별도 메서드에서 초기화하도록 분리한다.
2. 혹은 `RecordForm`을 MindAnalyzer에 넘길 때 구조체/DTO 복제를 수행해 실제 참조를 공유하지 않도록 한다.
3. 단기 대응으로는 `submit` 호출 시 폼 초기화를 제거하고 MindAnalyzer에서 결과를 안전하게 수신한 후 UI 계층에서 명시적으로 초기화하도록 수정한다.

```swift
// 단기 대응 예시
func submit() async throws {
    try await mindAnalyzer.analyze(recordForm: self)
    resetInputsIfNeeded() // MindAnalyzer 콜백 이후 호출
}
```

## 검증
1. 폼에 실제 데이터를 입력한 뒤 MindAnalyze를 호출한다.
2. MindAnalyzer 콜백에서 `RecordForm` 값이 유지되는지 확인한다.
3. API 응답을 정상적으로 UI에 적용하면 로딩이 종료되고 결과가 표시된다.
<img width="400" height="auto" alt="Simulator Screenshot - iPhone 17 Pro - 2025-11-19 at 14 34 44" src="https://github.com/user-attachments/assets/543f8c27-883a-4293-9d3b-06e625b1df5b" />

