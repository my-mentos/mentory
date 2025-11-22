# MentoryiOS

![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat-square&logo=swift)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey?style=flat-square)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue?style=flat-square)

## 목차

- [MentoryiOS](#mentoryios)
  - [목차](#목차)
  - [개요](#개요)
  - [사용 기술](#사용-기술)
    - [🏗️ 아키텍처 \& 디자인 패턴](#️-아키텍처--디자인-패턴)
    - [💾 데이터 관리](#-데이터-관리)
    - [🎤 음성 처리](#-음성-처리)
    - [🤖 AI \& LLM](#-ai--llm)
    - [📊 헬스케어 연동](#-헬스케어-연동)
    - [🔧 기타](#-기타)
  - [시작하기](#시작하기)
    - [필요 조건](#필요-조건)
    - [설치](#설치)
    - [환경 설정](#환경-설정)
    - [실행](#실행)
  - [소프트웨어 디자인](#소프트웨어-디자인)
  - [개발 문서](#개발-문서)
  - [트러블슈팅 문서](#트러블슈팅-문서)
  - [팀원](#팀원)

## 개요

Mentory는 STT와 LLM을 활용해 사용자의 감정을 기록·분석하고 맞춤형 조언을 제공하는 멘탈 케어 iOS 앱입니다. 일기처럼 텍스트·이미지·채팅으로 감정을 남기거나 음성을 iOS Speech Framework로 전사해 기록할 수 있으며, 전사된 데이터는 LLM이 감정 상태를 해석하고 캐릭터 기반 위로 멘트와 실천 가능한 Todo까지 추천합니다.

월간 감정 통계, 감정 캘린더, Alert/리마인드, 하루 한 줄 명언, 맞춤 행동 추천 등으로 사용자가 스스로의 변화를 추적할 수 있고, SwiftData·HealthKit 연동으로 안전한 백업과 헬스 데이터 확장이 가능합니다.

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

## 시작하기

### 필요 조건

<table>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-26.1+-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS">
    </td>
    <td>
      <b>macOS 26.1 이상</b>
    </td>
  </tr>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-26.1+-147EFB?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode">
    </td>
    <td>
      <b>Xcode 26.1 이상</b>
    </td>
  </tr>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-18.0+-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS">
    </td>
    <td>
      <b>iOS 18.0 이상</b> (시뮬레이터 또는 실제 디바이스)
    </td>
  </tr>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-6.0-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift">
    </td>
    <td>
      <b>Swift 6.0</b>
    </td>
  </tr>
</table>

### 설치

1. 저장소를 클론합니다.
   ```bash
   git clone https://github.com/EST-iOS4/Mentory-iOS.git
   cd Mentory-iOS
   ```

### 환경 설정

1. 저장소 루트에 있는 `Secrets.xcconfig.sample`을 복사하여 `Secrets.xcconfig`를 생성합니다.
   ```bash
   cp Secrets.xcconfig.sample Secrets.xcconfig
   ```
2. 새로 생성된 `Secrets.xcconfig`에 Alan API 키 등 민감한 값을 채웁니다.
   ```
   ALAN_API_KEY = your_api_key_here
   ```
   해당 파일은 `.gitignore`에 포함되어 있으니 저장소에 커밋되지 않습니다.

### 실행

1. Xcode에서 `Mentory/Mentory.xcodeproj`를 엽니다.
   ```bash
   open Mentory/Mentory.xcodeproj
   ```
2. 타겟 디바이스를 선택합니다 (시뮬레이터 또는 실제 디바이스).
3. `Cmd + R`을 눌러 앱을 빌드하고 실행합니다.

## 소프트웨어 디자인

아래 사진을 통해 MentoryiOS, MentoryLLM, MentoryDB 도메인을 확인할 수 있습니다.

<p align="center">
  <img src="mentory.png" alt="소프트웨어 디자인 다이어그램">
</p>

## 개발 문서

- [이슈(Issue) 작성하기](docs/write-issue/README.md)
- [SwiftUI에서 Combine 기반 MVVM 사용하기](docs/swiftui-combine-mvvm/README.md)
- [MVVM에 Swift Concurrency 도입하기](docs/mvvm-swift-concurrency/README.md)
- [SwiftData 구현 가이드](docs/swiftdata/README.md)
- [Alan API 사용법](docs/alan-api/README.md)
- [WatchOS 기초](docs/watchos/README.md)
- [WatchConnectivity 이해하기](docs/watchos/watchconnectivity.md)
- [Widget Extension 개념 이해하기](docs/Widget-Extension/README.md)
- [Firebase AI 사용하기](docs/firebase-ai/README.md)
- 브랜치 전략, TBD(Trunk-Based Development)

## 트러블슈팅 문서

아래는 팀원별로 개발을 진행하며 겪은 문제에 대한 트러블슈팅 문서입니다. 새로운 문서를 추가하려면 `docs/troubleshooting/<이름-폴더>/YYYYMMDD-short-title.md` 형식으로 새 마크다운 파일을 만들고, 아래에 문서 참조를 추가하면 됩니다.

1. 박재이
   - 작성된 문서 없음
2. 송지석
   - [2025-11-18 설정 탭 화면이 표시되지 않는 문제](docs/troubleshooting/jiseok/2025-11-18-Tabbar-view.md)
3. 구현모
   - [2025-11-17 앱 아이콘 설정](docs/troubleshooting/hyunmo/20251117-app-icon.md)
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
