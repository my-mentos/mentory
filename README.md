<!-- 프로젝트 개요 -->
<div align="center">
  <a href="https://github.com/EST-iOS4/Mentory">
    <img src="./mentory-icon.png" alt="Logo" width="110" height="110">
  </a>

  <h3>Mentory</h3>

  <p>
    텍스트·음성·사진 기반 감정 기록을 분석하여, AI가 감정과 사고 패턴을 파악하고 개인화된 리프레이밍 조언을 제공하는 멘탈 케어 앱
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

## 목차

- [목차](#목차)
- [앱 주요 기능](#앱-주요-기능)
- [스크린샷](#스크린샷)
- [사용 기술](#사용-기술)
- [시작하기](#시작하기)
  - [필요 조건](#필요-조건)
  - [설치](#설치)
  - [환경 설정](#환경-설정)
  - [실행](#실행)
- [소프트웨어 디자인](#소프트웨어-디자인)
- [개발 문서](#개발-문서)
- [트러블슈팅 문서](#트러블슈팅-문서)
- [팀원](#팀원)


---

## 앱 주요 기능

### ✏️ 감정 기록 (텍스트 / 음성 / 사진)
- 텍스트로 감정 기록
- 음성 입력 → 자동 텍스트 변환
- 사진 기반 상황 단서 감지

### 🧠 AI 감정 분석 & 사고 패턴 탐지
- ESTsoft Alan API 기반 감정/사고 패턴 분석
- Firebase AI Logic 기반 개인화 조언

### 👥 두 가지 AI 캐릭터 선택
- **냉철한 분석 캐릭터** (직설적·해결 중심)
- **따뜻한 분석 캐릭터** (공감 기반 리프레이밍)

### 📊 감정 변화 통계
- 일/주/월 감정 변화 그래프 제공
- 자주 등장하는 감정·사고 패턴 시각화

### 🔔 감정 기록 알림(Reminder)
- 원하는 시간에 기록 리마인드
- UserNotificationCenter 기반

### ⌚ WatchOS & Widget 지원
- WatchOS에서 빠르게 감정 기록
- 홈 위젯에서 기록/확인

---

## 스크린샷
> 실제 화면을 캡처해서 밑에다 넣기.

<div align="center">
  <img src="./screenshots/onboarding.png" width="240">
  <img src="./screenshots/home.png" width="240">
  <img src="./screenshots/record.png" width="240">
</div>

<div align="center" style="margin-top: 20px;">
  <img src="./screenshots/analysis.png" width="240">
  <img src="./screenshots/stats.png" width="240">
  <img src="./screenshots/settings.png" width="240">
</div>

---

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
      <td>🏗️ 아키텍처</td>
      <td>
        <ul>
          <li><strong>SwiftUI + MVVM</strong></li>
          <li><strong>Swift Concurrency</strong></li>
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
          <li><strong>Speech Framework</strong></li>
          <li><strong>AVFoundation</strong></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>🤖 LLM</td>
      <td>
        <ul>
          <li><strong>ESTSOFT Alan API</strong></li>
          <li><strong>Firebase AI Logic</strong></li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>


---

## 시작하기

### 필요 조건

<table>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-26.1+-147EFB?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode">
    </td>
    <td><b>Xcode 26.1 이상</b></td>
  </tr>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-18.0+-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS">
    </td>
    <td><b>iOS 18.0 이상</b></td>
  </tr>
  <tr>
    <td align="center" width="120">
      <img src="https://img.shields.io/badge/-6.0-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift">
    </td>
    <td><b>Swift 6.0</b></td>
  </tr>
</table>

### 설치

```bash
git clone https://github.com/EST-iOS4/Mentory-iOS.git
cd Mentory-iOS
```

### 환경 설정

```bash
git clone https://github.com/EST-iOS4/Mentory-iOS.git
cd Mentory-iOS
```

- `Secrets.xcconfig`에 Alan API Key 등 민감한 값 입력  
- 해당 파일은 `.gitignore` 처리됨

### 실행

```bash
open Mentory/Mentory.xcodeproj
```

Xcode에서 타겟 선택 → `Cmd + R` 실행

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
