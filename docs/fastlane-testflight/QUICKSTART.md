# Fastlane TestFlight 배포 - 빠른 시작 가이드

이 가이드는 가장 빠르게 fastlane을 설정하고 TestFlight에 배포하는 방법을 설명합니다.

## 1단계: fastlane 설치 (5분)

```bash
# 프로젝트 루트에서 실행
sudo gem install bundler:2.7.2
bundle install
```

## 2단계: API 키 설정

### 옵션 A: 팀원에게 API 키 받기 (2분) - 팀원용

이미 팀에서 API 키가 생성되었다면:

```bash
# 팀에서 받은 app_store_connect_api_key.json 파일을 fastlane/ 폴더로 복사
cp ~/Downloads/app_store_connect_api_key.json fastlane/
```

⚠️ **보안**: 이 파일은 1Password, Slack DM 등 안전한 방법으로만 공유하세요.

**→ 4단계로 이동**

### 옵션 B: 직접 API 키 생성 (8분) - 처음 설정하는 사람용

#### 2-1. App Store Connect에서 API 키 생성

1. [App Store Connect](https://appstoreconnect.apple.com/) 로그인
2. **Users and Access** → **Integrations** → **App Store Connect API**
3. **+** 버튼 클릭하여 API 키 생성
   - Name: `Fastlane CI`
   - Access: `App Manager`
4. 생성 후 **Download API Key** 클릭 (`AuthKey_XXXXXXXXXX.p8` 다운로드)
5. **Key ID**와 **Issuer ID** 복사해두기

#### 2-2. API 키 JSON 파일 생성

`fastlane/app_store_connect_api_key.json` 파일 생성:

```json
{
  "key_id": "ABCD123456",
  "issuer_id": "12345678-abcd-1234-abcd-123456789012",
  "key": "-----BEGIN PRIVATE KEY-----\n[AuthKey_*.p8 파일의 내용]\n-----END PRIVATE KEY-----",
  "duration": 1200,
  "in_house": false
}
```

**AuthKey_*.p8 내용 복사 방법:**

```bash
cat AuthKey_XXXXXXXXXX.p8
```

출력된 내용을 `key` 필드에 붙여넣습니다.

**→ 이 파일을 팀원들과 공유하세요**

## 3단계: 환경 변수 설정 (2분)

```bash
# .env 파일 생성
cp .env.sample .env
```

`.env` 파일 편집:

```bash
APPLE_ID=your.apple.id@example.com
APP_STORE_CONNECT_TEAM_ID=123456789
```

**Team ID 찾기:**
- [App Store Connect](https://appstoreconnect.apple.com/) → 우측 상단 사용자 이름 → **View Membership**
- 또는 팀 리더에게 문의

## 4단계: TestFlight 배포 실행! (10-15분)

```bash
bundle exec fastlane beta
```

완료! 🎉

## 빠른 체크리스트

### 처음 설정하는 사람 (API 키 생성자)

- [ ] Bundler 설치 및 `bundle install` 실행
- [ ] App Store Connect API 키 생성
- [ ] `AuthKey_*.p8` 파일 다운로드
- [ ] `fastlane/app_store_connect_api_key.json` 파일 생성
- [ ] **API 키 파일을 팀원과 공유**
- [ ] `.env` 파일 생성 및 설정
- [ ] `bundle exec fastlane beta` 실행

### 팀원 (API 키 받는 사람)

- [ ] Bundler 설치 및 `bundle install` 실행
- [ ] 팀에서 `app_store_connect_api_key.json` 파일 받기
- [ ] 받은 파일을 `fastlane/` 폴더에 복사
- [ ] `.env` 파일 생성 및 설정
- [ ] `bundle exec fastlane beta` 실행

## 문제가 생겼나요?

상세한 트러블슈팅은 [전체 가이드](./README.md#트러블슈팅)를 참고하세요.

## 자주 사용하는 명령어

```bash
# TestFlight 배포
bundle exec fastlane beta

# 빌드만 (업로드 안 함)
bundle exec fastlane build_only

# 테스트 실행
bundle exec fastlane test

# 인증서 동기화
bundle exec fastlane sync_certificates
```
