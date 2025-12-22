# Fastlane을 사용한 TestFlight 배포 자동화

이 문서는 fastlane을 사용하여 Mentory 앱을 TestFlight에 자동으로 배포하는 방법을 설명합니다.

## 목차

- [사전 준비](#사전-준비)
- [fastlane 설치](#fastlane-설치)
- [App Store Connect API 키 설정](#app-store-connect-api-키-설정)
- [환경 변수 설정](#환경-변수-설정)
- [사용 방법](#사용-방법)
- [트러블슈팅](#트러블슈팅)

## 사전 준비

### 1. Apple Developer Program 멤버십

- Apple Developer Program에 가입되어 있어야 합니다
- Team ID: `3X262XJF5T`
- 앱의 Bundle ID가 App Store Connect에 등록되어 있어야 합니다

### 2. Xcode 설정

- Xcode에서 Signing & Capabilities 설정이 완료되어 있어야 합니다
- 개발 인증서와 프로비저닝 프로파일이 정상적으로 설정되어 있어야 합니다

## fastlane 설치

### 1. Bundler를 사용한 설치 (권장)

프로젝트 루트 디렉토리에서 다음 명령을 실행합니다:

```bash
# Bundler 설치 (이미 설치되어 있다면 생략)
sudo gem install bundler:2.7.2

# 프로젝트 의존성 설치
bundle install
```

설치가 완료되면 `Gemfile.lock` 파일이 생성됩니다. 이 파일은 git에 커밋하지 않습니다.

### 2. fastlane 버전 확인

```bash
bundle exec fastlane --version
```

## App Store Connect API 키 설정

App Store Connect API 키를 사용하면 2단계 인증 없이 자동화된 배포가 가능합니다.

### 1. App Store Connect에서 API 키 생성

1. [App Store Connect](https://appstoreconnect.apple.com/)에 로그인
2. 왼쪽 사이드바에서 **Users and Access** 클릭
3. 상단 탭에서 **Integrations** > **App Store Connect API** 선택
4. **Generate API Key** 또는 **+** 버튼 클릭
5. 다음 정보를 입력:
   - **Name**: `Fastlane CI` (원하는 이름)
   - **Access**: `App Manager` 또는 `Developer` 선택
6. **Generate** 버튼 클릭
7. 생성된 키를 다운로드 (파일명: `AuthKey_XXXXXXXXXX.p8`)
   - ⚠️ **중요**: 이 파일은 한 번만 다운로드할 수 있습니다. 안전한 곳에 보관하세요.

### 2. API 키 정보 확인

API 키를 생성하면 다음 정보가 표시됩니다:

- **Issuer ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` 형식
- **Key ID**: `XXXXXXXXXX` (10자리 영숫자)

이 정보를 메모해두세요.

### 3. API 키 JSON 파일 생성

`fastlane/app_store_connect_api_key.json` 파일을 생성합니다:

```json
{
  "key_id": "여기에_Key_ID_입력",
  "issuer_id": "여기에_Issuer_ID_입력",
  "key": "-----BEGIN PRIVATE KEY-----\n여기에_AuthKey_p8_파일의_내용을_붙여넣기\n-----END PRIVATE KEY-----",
  "duration": 1200,
  "in_house": false
}
```

#### AuthKey_*.p8 파일 내용 확인 방법:

```bash
cat AuthKey_XXXXXXXXXX.p8
```

출력된 내용을 `key` 필드에 복사합니다. 줄바꿈은 `\n`으로 표시됩니다.

**예시:**
```json
{
  "key_id": "ABCD123456",
  "issuer_id": "12345678-abcd-1234-abcd-123456789012",
  "key": "-----BEGIN PRIVATE KEY-----\nMIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...\n-----END PRIVATE KEY-----",
  "duration": 1200,
  "in_house": false
}
```

⚠️ **보안 주의사항**:
- 이 파일은 **절대 git에 커밋하지 마세요** (`.gitignore`에 이미 추가되어 있습니다)
- 팀원과 공유할 때는 안전한 방법(1Password, 암호화된 저장소 등)을 사용하세요

## 환경 변수 설정

### 1. .env 파일 생성

```bash
cp .env.sample .env
```

### 2. .env 파일 수정

```bash
# Apple Developer Account
APPLE_ID=your.apple.id@example.com
APP_STORE_CONNECT_TEAM_ID=123456789  # App Store Connect Team ID
```

#### App Store Connect Team ID 찾기:

1. [App Store Connect](https://appstoreconnect.apple.com/)에 로그인
2. 상단 오른쪽의 사용자 이름 클릭
3. **View Membership** 클릭
4. Team ID를 확인하고 복사

⚠️ `.env` 파일도 git에 커밋하지 마세요 (`.gitignore`에 추가 권장).

## 사용 방법

### 1. TestFlight에 베타 빌드 배포

```bash
bundle exec fastlane beta
```

이 명령은 다음을 자동으로 수행합니다:

1. 빌드 번호 자동 증가
2. 앱 빌드 (Release 모드)
3. App Store용 IPA 파일 생성
4. TestFlight에 업로드
5. 빌드 처리 대기 (선택적)

### 2. 빌드만 수행 (업로드 없이)

```bash
bundle exec fastlane build_only
```

### 3. 인증서 및 프로비저닝 프로파일 동기화

```bash
bundle exec fastlane sync_certificates
```

### 4. 테스트 실행

```bash
bundle exec fastlane test
```

### 5. 스크린샷 캡처

```bash
bundle exec fastlane screenshots
```

## 배포 시 변경사항 노트 추가

배포할 때마다 변경사항을 테스터에게 알리려면 `fastlane/changelog.txt` 파일을 생성하세요:

```bash
echo "버그 수정 및 성능 개선" > fastlane/changelog.txt
bundle exec fastlane beta
```

## CI/CD 통합

### GitHub Actions 예시

`.github/workflows/testflight.yml` 파일을 생성:

```yaml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true

      - name: Install dependencies
        run: bundle install

      - name: Setup App Store Connect API Key
        env:
          API_KEY_JSON: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        run: |
          echo "$API_KEY_JSON" > fastlane/app_store_connect_api_key.json

      - name: Deploy to TestFlight
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APP_STORE_CONNECT_TEAM_ID: ${{ secrets.APP_STORE_CONNECT_TEAM_ID }}
        run: bundle exec fastlane beta
```

**GitHub Secrets 설정**:
- `APP_STORE_CONNECT_API_KEY`: API 키 JSON 파일의 전체 내용
- `APPLE_ID`: Apple ID 이메일
- `APP_STORE_CONNECT_TEAM_ID`: App Store Connect Team ID

## 트러블슈팅

### 1. "No signing certificate found" 에러

**원인**: 개발 인증서가 설정되지 않았습니다.

**해결**:
```bash
bundle exec fastlane sync_certificates
```

### 2. "Two-factor authentication" 에러

**원인**: App Store Connect API 키가 올바르게 설정되지 않았습니다.

**해결**:
1. `fastlane/app_store_connect_api_key.json` 파일이 존재하는지 확인
2. JSON 파일의 형식이 올바른지 확인
3. Key ID와 Issuer ID가 정확한지 확인

### 3. "Invalid provisioning profile" 에러

**원인**: 프로비저닝 프로파일이 만료되었거나 올바르지 않습니다.

**해결**:
1. Apple Developer Portal에서 프로비저닝 프로파일 갱신
2. Xcode에서 Signing & Capabilities 재설정
3. `bundle exec fastlane sync_certificates` 실행

### 4. "Build number already exists" 에러

**원인**: 동일한 빌드 번호가 이미 TestFlight에 업로드되어 있습니다.

**해결**:
- Fastfile에서 `increment_build_number`가 정상 동작하는지 확인
- 또는 Xcode에서 수동으로 빌드 번호 증가

### 5. 빌드 시간이 너무 오래 걸림

**해결**:
- `skip_waiting_for_build_processing: true` 옵션 사용 (Fastfile에 이미 설정됨)
- 빌드 처리는 Apple 서버에서 계속 진행되며, App Store Connect에서 확인 가능

## 참고 자료

- [Fastlane 공식 문서](https://docs.fastlane.tools/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/) - 팀 인증서 관리
- [Fastlane Gym](https://docs.fastlane.tools/actions/gym/) - 앱 빌드

## 추가 개선사항

### 1. Fastlane Match 도입

팀에서 인증서와 프로비저닝 프로파일을 공유하려면 [Fastlane Match](https://docs.fastlane.tools/actions/match/)를 사용하는 것을 권장합니다.

### 2. Slack 알림 통합

배포 완료 시 Slack 알림을 받으려면 Fastfile에 다음을 추가:

```ruby
slack(
  message: "새 베타 빌드가 TestFlight에 배포되었습니다!",
  slack_url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
)
```

### 3. 자동 스크린샷

App Store 스크린샷을 자동화하려면 [Snapshot](https://docs.fastlane.tools/actions/snapshot/)을 사용하세요.
