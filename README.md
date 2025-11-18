# Mentory-iOS

## 개요

Mentory는 STT와 LLM을 활용해 사용자의 감정을 기록·분석하고 맞춤형 조언을 제공하는 멘탈 케어 iOS 앱입니다. 일기처럼 텍스트·이미지·채팅으로 감정을 남기거나 음성을 iOS Speech Framework로 전사해 기록할 수 있으며, 전사된 데이터는 LLM이 감정 상태를 해석하고 캐릭터 기반 위로 멘트와 실천 가능한 Todo까지 추천합니다.

월간 감정 통계, 감정 캘린더, Alert/리마인드, 하루 한 줄 명언, 맞춤 행동 추천 등으로 사용자가 스스로의 변화를 추적할 수 있고, SwiftData·HealthKit 연동으로 안전한 백업과 헬스 데이터 확장이 가능합니다.

## 소프트웨어 디자인

아래 사진을 통해 MentoryiOS, MentoryLLM, MentoryDB 도메인을 확인할 수 있습니다.

<p align="center">
  <img src="mentory.png" alt="소프트웨어 디자인 다이어그램">
</p>

## 사용 기술

### 🏗️ 아키텍처 & 디자인 패턴
- **SwiftUI** - 선언형 UI 프레임워크
- **MVVM** - Combine 기반 반응형 아키텍처
- **Swift Concurrency** - async/await 및 Task 기반 비동기 처리 (Swift 6)

### 💾 데이터 관리
- **SwiftData** - 안전한 로컬 데이터 영속화 및 백업
- **UserDefaults** - 사용자 설정 및 간단한 데이터 저장

### 🎤 음성 처리
- **Speech Framework** - iOS 기본 음성 인식 및 전사(STT)

### 🤖 AI & LLM
- **ESTSOFT Alan LLM API** - 감정 분석 및 맞춤형 조언 생성

### 📊 헬스케어 연동
- **HealthKit** - 건강 데이터 확장 및 통합

### 🔧 기타
- **Combine** - 반응형 프로그래밍 및 이벤트 처리

## 개발 문서

- [이슈(Issue) 작성하기](docs/write-issue/README.md)
- [SwiftUI에서 Combine 기반 MVVM 사용하기](docs/swiftui-combine-mvvm/README.md)
- [MVVM에 Swift Concurrency 도입하기](docs/mvvm-swift-concurrency/README.md)
- [Alan API 사용법](docs/alan-api/README.md)
- 브랜치 전략, TBD(Trunk-Based Development)

## 트러블슈팅 문서

아래는 팀원별로 개발을 진행하며 겪은 문제에 대한 트러블슈팅 문서입니다. 새로운 문서를 추가하려면 `docs/troubleshooting/<이름-폴더>/YYYYMMDD-short-title.md` 형식으로 새 마크다운 파일을 만들고, 아래에 문서 참조를 추가하면 됩니다.

1. 박재이
   - 작성된 문서 없음
2. 송지석
   - 작성된 문서 없음
3. 구현모
   - 작성된 문서 없음
4. 김민우
   - [2024-09-18 음성 전사 중 앱 크래시](docs/troubleshooting/kim-minwoo/20240918-speech-transcript-crash.md)

## 팀원

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/dearjaypark">
        <img src="https://github.com/dearjaypark.png" width="100" height="100" style="border-radius: 50%;"><br>
        <b>박재이</b>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/ji-seok-Song">
        <img src="https://github.com/ji-seok-Song.png" width="100" height="100" style="border-radius: 50%;"><br>
        <b>송지석</b>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/funrace2">
        <img src="https://github.com/funrace2.png" width="100" height="100" style="border-radius: 50%;"><br>
        <b>구현모</b>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/mandooplz">
        <img src="https://github.com/mandooplz.png" width="100" height="100" style="border-radius: 50%;"><br>
        <b>김민우</b>
      </a>
    </td>
  </tr>
  <tr>
    <td align="center">iOS Developer</td>
    <td align="center">iOS Developer</td>
    <td align="center">iOS Developer</td>
    <td align="center">iOS Developer</td>
  </tr>
</table>
