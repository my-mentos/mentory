# iOS Widget Extension 구조 이해하기

## 목차

- 개요
- 배경 지식
- Widget Extension 구성 요소
    - 1. MentoryWidget
    - 2. MentoryWidgetControl
    - 3. MentoryWidgetLiveActivity
    - 4. AppIntent
    - 5. MentoryWidgetBundle
- 각 위젯 구조 비교
- 참고 자료

---

# 개요

Widget Extension은 iOS 14~17 사이에 계속 확장된 기능으로,

**사용자가 앱을 열지 않아도 홈 화면·잠금 화면·Dynamic Island에서 앱 기능을 빠르게 접근**할 수 있게 해준다.

Widget Extension을 생성하면 보통 아래 파일들이 자동 생성된다:

- `MentoryWidget.swift`
- `MentoryWidgetControl.swift`
- `MentoryWidgetLiveActivity.swift`
- `AppIntent.swift`
- `MentoryWidgetBundle.swift`

이 문서는 위 파일들이 어떤 역할을 하는지, 언제 사용하는지,

그리고 Mentory 프로젝트에서는 어떻게 활용 가능한지를 설명한다.

---

# 배경 지식

Widget은 크게 세 가지 유형으로 구성된다:

### 1. **정적/동적 홈 화면 위젯 (WidgetKit)**

iOS 14~16부터 사용 가능

- 홈 화면에 고정됨
- 시간에 따라 데이터를 갱신하는 Timeline 기반

### 2. **인터랙티브 위젯 (ControlWidget)**

iOS 17 이후 추가

- 위젯 안에서 버튼을 누르는 등 직접 조작 가능
- AppIntent 기반

### 3. **Live Activity / Dynamic Island (ActivityKit)**

iOS 16 이후

- 실시간 정보 업데이트
- 잠금 화면 또는 Dynamic Island에서 동작

이 세 가지 유형을 한 번에 포함하는 템플릿을 만들기 때문에

Widget Extension 생성 시 파일이 여러 개 생기게 된다.

---

# Widget Extension 구성 요소

## 1. MentoryWidget — **홈 화면 위젯**

### 개념

사용자가 홈 화면에 고정시켜 사용할 수 있는 기본 위젯.

날씨, 달력, 사진 위젯처럼 **정기적으로 업데이트(Timeline)** 된다.

### 포함된 구성

- `Provider`: 위젯에 표시할 데이터를 시간에 따라 제공
- `TimelineEntry`: 특정 시점의 데이터
- `EntryView`: 실제 UI
- `Widget`: 지원하는 사이즈, 설명, Intent 설정 등

### Mentory에서의 활용 예

- “일기 작성 위젯”
- “오늘의 명언 위젯”
- “감정 요약 위젯”

### 대표 코드

```swift
struct MentoryWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "MentoryWidget",
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            MentoryWidgetEntryView(entry: entry)
        }
    }
}

```

---

## 2. MentoryWidgetControl — **인터랙티브 위젯**

### 개념

iOS 17에서 추가된 새로운 위젯 유형.

홈 화면 위젯 안에서 **버튼, 토글 등 UI 컨트롤을 직접 조작**할 수 있다.

### 특징

- 앱을 열지 않아도 기능 실행 가능
- AppIntent 기반의 즉각적인 액션 처리
- 기존 위젯보다 강력한 상호작용 제공

### 활용 예

- 위젯에서 감정 이모티콘 바로 선택
- 일기 작성 “완료” 버튼
- 하루 목표 체크박스

### Mentory에서의 가능성

아직 사용 계획이 없다면 **삭제해도 괜찮은 파일**.

---

## 3. MentoryWidgetLiveActivity — **Live Activity / Dynamic Island**

### 개념

잠금 화면 또는 Dynamic Island에서 표시되는 **실시간 업데이트 UI**.

### 특징

- ActivityKit 기반
- 앱이 백그라운드여도 계속 업데이트
- iPhone 14 Pro+에서 Dynamic Island 지원

### 예시

- 배달 상태 표시(배민/쿠팡이츠)
- 운동 기록 실시간 표시
- 타이머

### Mentory에서의 활용 가능성

- “5분 심호흡 모드”
- “일기 작성 챌린지 남은 시간 표시”
- “감정 체크 루틴”

하지만 현재 사용하지 않으면 삭제해도 됨.

---

## 4. AppIntent — **위젯의 설정값과 행동 정의**

### 개념

위젯이 “어떤 데이터를 받을지”, “사용자가 어떤 행동을 할 수 있는지” 정의하는 파일.

Timeline 기반 위젯 + ControlWidget 모두 이 구조를 사용한다.

### 기능

- 위젯 설정 제공 (예: 즐겨찾는 이모지 선택)
- 위젯 버튼이 눌렸을 때 실행되는 액션 정의
- 인풋 값을 받아서 EntryView에 전달

### 대표 구조

```swift
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    @Parameter(title: "Emoji")
    var favoriteEmoji: String
}

```

---

## 5. MentoryWidgetBundle — **여러 위젯을 하나로 묶는 컨테이너**

### 개념

여러 개의 위젯 파일을 하나의 Widget Extension에 포함시키기 위한 컨테이너.

### 필요 이유

iOS가 Widget Extension 내부 위젯들을 모두 읽어들이기 위해

반드시 하나의 `@main` 진입점을 가져야 함.

### 자동 생성되는 코드

```swift
@main
struct MentoryWidgetBundle: WidgetBundle {
    var body: some Widget {
        MentoryWidget()
        MentoryWidgetControl()
        MentoryWidgetLiveActivity()
    }
}

```

### Mentory에서의 활용

- 위젯을 여러 개 추가할수록 이 파일에 하나씩 추가됨
- 사용하지 않는 위젯은 body에서 삭제만 하면 됨

---

# 각 위젯 구조 비교

| 파일명 | 기능 | 기술 기반 | 사용 위치 | Mentory에서 필요 여부 |
| --- | --- | --- | --- | --- |
| **MentoryWidget** | 홈 화면 위젯 | WidgetKit (Timeline) | 홈 화면 / 스택 | ✔ 필요함 |
| **MentoryWidgetControl** | 인터랙티브 위젯 | WidgetKit + AppIntent | 홈 화면 | 옵션 (필요시) |
| **MentoryWidgetLiveActivity** | 실시간 UI | ActivityKit | 잠금 화면 / Dynamic Island | 옵션 |
| **AppIntent** | 위젯 입력값/행동 정의 | AppIntents | 위젯 설정 화면 | ✔ 필요함 |
| **MentoryWidgetBundle** | 위젯 묶음 관리 | WidgetBundle | Extension 진입점 | ✔ 필수 |

---

# 참고 자료

- Apple: [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- Apple: [Building Interactive Widgets (iOS 17)](https://developer.apple.com/documentation/widgetkit/building-interactive-widgets)
- Apple: [ActivityKit](https://developer.apple.com/documentation/activitykit)
- Apple: [Configuring App Intents](https://developer.apple.com/documentation/appintents)
- Apple: [WidgetBundle](https://developer.apple.com/documentation/widgetkit/widgetbundle)
