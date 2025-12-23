<!-- 프로젝트 개요 -->

<div align="center">
  <a href="https://github.com/EST-iOS4/Mentory">
    <img src="./mentory-icon.png" alt="Logo" width="110" height="110">
  </a>

  <h3>Mentory</h3>

  <p>
    감정을 기록하면 LLM이 분석해 맞춤 행동을 제안하는 SwiftUI 멘탈케어 앱
  </p>

  <p>
    <img src="https://img.shields.io/badge/iOS-1A1A1A?style=for-the-badge&logo=apple&logoColor=white" />
    <img src="https://img.shields.io/badge/watchOS-000000?style=for-the-badge&logo=apple&logoColor=white" />
    <img src="https://img.shields.io/badge/Widget-FF7F2A?style=for-the-badge&logo=swift&logoColor=white" />
  </p>

  <p>
    <img src="https://img.shields.io/badge/SwiftUI-F05138?style=for-the-badge&logo=swift&logoColor=white" />
    <img src="https://img.shields.io/badge/Combine-333333?style=for-the-badge&logo=swift&logoColor=white" />
    <img src="https://img.shields.io/badge/Swift%206-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
  </p>
</div>

<p align="center">
  <img src="./mentory-intro.png" alt="App Introduction" width="800">
</p>

## 목차

- [목차](#목차)
- [관련 링크](#관련-링크)
- [사용 기술](#사용-기술)
- [시작하기](#시작하기)
  - [필요 조건](#필요-조건)
  - [설치 방법](#설치-방법)
  - [환경 설정](#환경-설정)
  - [실행 방법](#실행-방법)
- [소프트웨어 디자인](#소프트웨어-디자인)
- [프로젝트 구조](#프로젝트-구조)
- [개발 문서](#개발-문서)
- [트러블슈팅 문서](#트러블슈팅-문서)
- [팀원](#팀원)

## 관련 링크

> [!NOTE]
> 프로젝트를 빌드하기 위해서는 Secrets.xcconfig 와 GoogleService-Info.plist 파일이 필요합니다.

- [작업 진행 상황](https://www.figma.com/board/SiHyXGeXghxikBKJqoxnkh/%EC%A7%84%ED%96%89-%EC%83%81%ED%99%A9?node-id=0-1&t=87sDM1UrF9fC4KOp-1)

## 스크린샷

<table>
  <tr>
    <td align="center" width="25%">
      <img src="./screenshots/todayboard.png" alt="todayboard" width="100%">
      <br>
      <b>오늘의 감정 보드</b>
      <br>
      <sub>오늘 하루의 감정 기록</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/suggestion.png" alt="suggestion" width="100%">
      <br>
      <b>활동 추천</b>
      <br>
      <sub>AI가 추천하는 맞춤형 활동</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/badge.png" alt="badge" width="100%">
      <br>
      <b>뱃지</b>
      <br>
      <sub>기록 달성에 따른 뱃지 획득</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/todayboard-record.png" alt="todayboard-record" width="100%">
      <br>
      <b>기록 히스토리</b>
      <br>
      <sub>이틀 전까지 기록 가능</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="./screenshots/recordform.png" alt="recordform" width="100%">
      <br>
      <b>감정 기록 폼</b>
      <br>
      <sub>텍스트, 음성, 사진 기록</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/recordform-pic.png" alt="recordform-pic" width="100%">
      <br>
      <b>사진으로 기록</b>
      <br>
      <sub>이미지를 통한 감정 표현</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/recordform-audio.png" alt="recordform-audio" width="100%">
      <br>
      <b>음성으로 기록</b>
      <br>
      <sub>음성 녹음을 통한 감정 기록</sub>
    </td>
    <td align="center" width="25%">
      <img src="./screenshots/analyze.png" alt="analyze" width="100%">
      <br>
      <b>AI 감정 분석</b>
      <br>
      <sub>LLM 기반 감정 분석, 조언</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="./screenshots/setting.png" alt="setting" width="100%">
      <br>
      <b>설정</b>
      <br>
      <sub>알림 및 개인 설정 관리</sub>
    </td>
    <td align="center" width="25%">
      <!-- 추가 스크린샷 -->
    </td>
    <td align="center" width="25%">
      <!-- 추가 스크린샷 -->
    </td>
    <td align="center" width="25%">
      <!-- 추가 스크린샷 -->
    </td>
  </tr>
</table>

## 사용 기술

<table>
  <thead>
    <tr>
      <th>카테고리</th>
      <th>기술</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td >🏗️ 아키텍처</td>
      <td>
        <ul>
          <li><strong>SwiftUI + MVVM</strong></li>
          <li><strong>Combine</strong></li>
          <li><strong>Swift Concurrency(Swift 6)</strong></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>💾 데이터 관리</td>
      <td>
        <ul>
          <li><strong>SwiftData</strong></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>🎤 음성 처리</td>
      <td>
        <ul>
          <li><strong>AVFoundation</strong></li>
          <li><strong>Speech Framework</strong></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>🤖 LLM</td>
      <td>
        <ul>
          <li><strong>ESTSOFT Alan LLM API</strong></li>
          <li><strong>Firebase AI Logic</strong></li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

## 시작하기

### 필요 조건

<table>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-26.1+-147EFB?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode">
    </td>
    <td>
      <b>Xcode 26.1 이상</b>
    </td>
  </tr>
  <tr>
    <td align="center" width="">
      <img src="https://img.shields.io/badge/-26.0+-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS">
    </td>
    <td>
      <b>iOS 26.0 이상</b> (시뮬레이터 또는 실제 디바이스)
    </td>
  </tr>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-26.0+-000000?style=for-the-badge&logo=apple&logoColor=white" alt="watchOS">
    </td>
    <td>
      <b>watchOS 26.0 이상</b>
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

### 설치 방법

1. **저장소 클론**
   ```bash
   git clone https://github.com/EST-iOS4/Mentory.git
   cd Mentory
   ```

2. **프로젝트 열기**
   ```bash
   cd Mentory
   open Mentory.xcodeproj
   ```

### 환경 설정

#### 1. ESTSOFT Alan LLM API 토큰 설정

1. `Secrets.xcconfig.sample` 파일을 복사하여 `Secrets.xcconfig` 파일 생성
   ```bash
   cp Mentory/Secrets.xcconfig.sample Mentory/Secrets.xcconfig
   ```

2. `Secrets.xcconfig` 파일을 열어 ESTSOFT에서 제공받은 API 토큰 입력
   ```
   TOKEN = 여기에-발급받은-토큰-입력
   ```

3. Xcode에서 프로젝트 설정 확인
   - [Mentory.xcodeproj](Mentory/Mentory.xcodeproj)를 선택
   - **Info** 탭에서 `ALAN_API_TOKEN` 값이 `$(TOKEN)`으로 설정되어 있는지 확인

#### 2. Firebase 설정

1. [Firebase Console](https://console.firebase.google.com/)에서 프로젝트 생성

2. iOS 앱 추가 및 `GoogleService-Info.plist` 다운로드

3. 다운로드한 파일을 프로젝트의 `Mentory/Mentory/` 디렉토리에 추가
   - Xcode에서 [Mentory/Mentory](Mentory/Mentory) 폴더에 드래그 앤 드롭
   - **Copy items if needed** 체크

4. Firebase AI 기능 활성화
   - Firebase Console에서 **Build** > **AI** 메뉴로 이동
   - Gemini API 활성화

### 실행 방법

#### iOS 앱 실행

1. Xcode에서 타겟을 **Mentory**로 선택
2. 시뮬레이터 또는 실제 디바이스 선택
3. `Cmd + R` 또는 실행 버튼 클릭

#### watchOS 앱 실행

1. Xcode에서 타겟을 **MentoryWatch Watch App**으로 선택
2. Watch 시뮬레이터 선택
3. `Cmd + R` 또는 실행 버튼 클릭

> **참고**: watchOS 앱을 실행하려면 먼저 iOS 앱이 실행되어 있어야 데이터 동기화가 정상적으로 작동합니다.

#### 위젯 테스트

1. iOS 앱을 먼저 실행
2. 홈 화면으로 이동
3. 위젯 추가 화면에서 **Mentory** 위젯 선택
4. 원하는 크기의 위젯을 홈 화면에 배치

## 소프트웨어 디자인

아래 사진을 통해 MentoryiOS, MentoryLLM, MentoryDB 도메인을 확인할 수 있습니다.

<p align="center">
  <img width="80%" height="auto" alt="image" src="https://github.com/user-attachments/assets/6c348677-a126-497d-8d30-dc8dd29528aa" />
</p>

<p align="center">
  <img src="mentory.png" alt="소프트웨어 디자인 다이어그램">
</p>

## 프로젝트 구조

```
Mentory/
├── Mentory/                          # 메인 iOS 앱
│   ├── MentoryApp.swift             # 앱 진입점
│   ├── Domain/                      # 비즈니스 로직 계층
│   │   ├── MentoryiOS.swift        # 메인 도메인 모델
│   │   ├── TodayBoard/             # 오늘의 감정 기록 관련 도메인
│   │   │   ├── TodayBoard.swift
│   │   │   ├── RecordForm/         # 감정 기록 폼
│   │   │   ├── MentorMessage/      # 멘토 메시지
│   │   │   └── Suggestion/         # 활동 추천
│   │   ├── Onboarding/             # 온보딩 도메인
│   │   └── SettingBoard/           # 설정 도메인
│   ├── Presentation/                # UI 계층 (SwiftUI Views & ViewModels)
│   │   ├── Components/             # 재사용 가능한 UI 컴포넌트
│   │   ├── TodayBoard/             # 오늘의 감정 기록 화면
│   │   ├── Onboarding/             # 온보딩 화면
│   │   └── SettingBoard/           # 설정 화면
│   ├── Adapter/                     # 외부 서비스 어댑터 계층
│   │   ├── AlanLLM/                # ESTSOFT Alan LLM 어댑터
│   │   ├── AlanLLMMock/            # Alan LLM 목 객체
│   │   ├── FirebaseLLM/            # Firebase AI 어댑터
│   │   ├── FirebaseLLMMock/        # Firebase LLM 목 객체
│   │   ├── MentoryDB/              # 데이터베이스 어댑터
│   │   ├── MentoryDBMock/          # DB 목 객체
│   │   └── Notification/           # 알림 어댑터
│   ├── Service/                     # 서비스 계층
│   │   ├── Microphone/             # 음성 녹음 서비스
│   │   ├── ImagePicker/            # 이미지 선택 서비스
│   │   └── WatchConnectivity/      # Watch 연동 서비스
│   ├── Assets.xcassets/            # 이미지, 컬러 리소스
│   ├── GoogleService-Info.plist    # Firebase 설정 파일
│   └── Info.plist                  # 앱 설정 파일
│
├── MentoryDB/                       # 데이터베이스 모듈
│   └── Domain/                     # DB 도메인 모델
│       └── DailyRecord/            # 일일 감정 기록 모델
│
├── MentoryWatch Watch App/          # watchOS 앱
│   ├── Domain/                     # Watch 앱 비즈니스 로직
│   ├── Service/                    # Watch 앱 서비스
│   └── Presentation/.              # UI 계층
│
├── MentoryWidget/                   # 위젯 확장
│   ├── MentoryWidgetBundle.swift   # 위젯 번들
│   └── Presentation/               # 위젯 UI
│
├── Values/                          # 공유 값 타입 및 프로토콜
│   ├── MentoryiOS/                 # iOS 앱 관련 값 타입
│   ├── MentoryDB/                  # DB 관련 값 타입
│   ├── AlanLLM/                    # Alan LLM 관련 값 타입
│   └── FirebaseLLM/                # Firebase LLM 관련 값 타입
│
├── MentoryTests/                    # 단위 테스트
│   ├── TodayBoard/                 # TodayBoard 도메인 테스트
│   └── Onboarding/                 # Onboarding 도메인 테스트
│
├── Secrets.xcconfig                 # API 키 설정 파일 (git에서 제외됨)
└── Secrets.xcconfig.sample          # API 키 설정 템플릿
```

### 아키텍처 설명

이 프로젝트는 **MVVM 패턴**과 **클린 아키텍처** 원칙을 따라 설계되었습니다:

- **Domain**: 비즈니스 로직과 규칙을 담당하는 핵심 계층
- **Presentation**: SwiftUI 뷰와 뷰모델을 포함하는 UI 계층
- **Adapter**: 외부 서비스(LLM, DB, 알림 등)와의 통신을 담당하는 계층
- **Service**: 공통 기능(마이크, 이미지 피커, Watch 연동)을 제공하는 계층
- **Values**: 도메인 간 공유되는 값 타입과 프로토콜

각 계층은 의존성 역전 원칙(DIP)을 따르며, Mock 객체를 통해 테스트 가능하도록 설계되었습니다.

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

## 트러블슈팅 문서

아래는 팀원별로 개발을 진행하며 겪은 문제에 대한 트러블슈팅 문서입니다. 새로운 문서를 추가하려면 `docs/troubleshooting/<이름-폴더>/YYYYMMDD-short-title.md` 형식으로 새 마크다운 파일을 만들고, 아래에 문서 참조를 추가하면 됩니다.

1. 박재이
   - [2025-11-19 MindAnalyze API 호출 시 결과 미반환](docs/troubleshooting/parkjay/mindanalyze-recordform-reset.md)
2. 송지석
   - [2025-11-18 설정 탭 화면이 표시되지 않는 문제](docs/troubleshooting/jiseok/2025-11-18-Tabbar-view.md)
   - [2025-12-09 App Group & Signing — “Unknown Name (Team ID)” 문제](docs/troubleshooting/jiseok/2025-12-9-appgroup-signing.md)
3. 구현모
   - [2025-11-17 앱 아이콘 설정](docs/troubleshooting/hyeonmo/20251117-app-icon.md)
   - [2025-12-02 WatchConnectivity MainActor 동시성 충돌](docs/troubleshooting/hyeonmo/20251202-watchconnectivity.md)
   - [2025-12-03 WatchConnectivity Manager-Engine 분리 리팩토링](docs/troubleshooting/hyeonmo/20251203-watchconnectivity-refactoring.md)
   - [2025-12-04 Firebase LLM 음성 파일 포맷 오류](docs/troubleshooting/hyeonmo/20251204-firebase-audio-format.md)
4. 김민우
   - 작성된 문서 없음

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
