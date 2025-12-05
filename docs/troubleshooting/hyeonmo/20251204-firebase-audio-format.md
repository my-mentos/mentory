# 2025-12-04 Firebase LLM 음성 파일 포맷 오류

## 이슈 개요

- **증상**: AudioEngine으로 녹음한 음성 파일을 Firebase LLM에 전송 시 "Invalid input data" 오류 발생.
- **영향 범위**: 모든 음성 입력 기반 감정 분석 기능.
- **감지 배경**: 멀티모달 입력(텍스트 + 이미지 + 음성) 구현 후, 음성이 포함된 요청에서만 Firebase API 호출 실패.

## 진단 과정

1. **증상 확인**
   - 파일 생성/읽기: ✅ 정상
   - Firebase 전송: ❌ "Invalid input data. Please check if the video data is valid."
   - Assets의 샘플 m4a 파일은 정상 작동

2. **근본 원인**
   ```swift
   // AudioEngine.swift (문제 코드)
   let fileURL = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
   let recordingFormat = inputNode.outputFormat(forBus: 0)  // PCM 포맷
   avAudioFile = try AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings)
   ```

   **핵심 문제**: PCM 데이터를 .m4a 확장자로 저장
   - `inputNode.outputFormat`: **PCM** 포맷 반환
   - `.m4a` 확장자: **AAC 코덱** 필요
   - 결과: 파일 헤더와 실제 데이터 불일치 → Firebase 파싱 실패

3. **포맷 테스트 결과**
   - ❌ CAF: Firebase 미지원
   - ✅ WAV: Firebase 지원 + PCM 데이터 저장 가능

## 해결 방법

### 1. AudioEngine 파일 확장자 변경

```swift
// ✅ Mentory/Service/Microphone/AudioEngine.swift
let fileURL = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).wav")
```

### 2. FirebaseLLM MIME 타입 수정

```swift
// ✅ Mentory/Adapter/FirebaseLLM/FirebaseLLM.swift
if let voiceURL = question.voiceURL {
    let voiceData = try Data(contentsOf: voiceURL)
    let mimeType = "audio/wav"
    parts.append(InlineDataPart(data: voiceData, mimeType: mimeType))
}
```

### 3. 멀티모달 프롬프트 강화

```swift
// ✅ Values/MentoryiOS/MentoryCharacter.swift
case .cool:
    return "... 음성이 첨부된 경우, 말투, 톤, 말하는 속도 등에서 드러나는 감정 상태도 객관적으로 분석해줘. 이미지가 첨부된 경우, 이미지 속 장소, 사물, 분위기가 사용자의 감정과 상황에 어떤 영향을 미치는지 논리적으로 파악해줘."

case .warm:
    return "... 음성이 첨부된 경우, 말투나 톤에서 느껴지는 감정도 따뜻하게 공감해주고, 이미지가 첨부된 경우 이미지 속 상황이나 분위기도 감정에 공감하는 근거로 활용해줘."
```

## 회고 및 팁

### 배운 점

1. **파일 확장자 ≠ 실제 데이터 포맷**: `.m4a`는 컨테이너일 뿐, AAC 코덱 데이터가 필요
2. **AVAudioEngine의 기본 동작**: `inputNode.outputFormat`은 항상 PCM 반환, 자동 변환 안 함
3. **Firebase 지원 포맷**: WAV, M4A(AAC), MP3 지원 / CAF는 Apple 전용이라 미지원
4. **복잡도 관리**: 변환 로직(CAF→M4A) 대신 WAV 직접 사용으로 단순화

### 예방 조치

1. **오디오 구현 체크리스트**
   - [ ] 녹음 엔진의 출력 포맷 확인 (PCM vs AAC)
   - [ ] 타겟 API 지원 포맷 확인
   - [ ] 파일 확장자와 실제 데이터 일치 검증

2. **테스트 방법**
   ```bash
   # 터미널에서 파일 포맷 확인
   $ file recording_XXX.wav
   recording_XXX.wav: RIFF data, WAVE audio, Microsoft PCM, 16 bit, mono 48000 Hz
   ```

3. **로그 확인**
   ```
   ✅ "오디오 파일 저장 완료: recording_XXX.wav"
   ✅ "음성 파일 전송 준비 완료 (MIME: audio/wav)"
   ✅ "멀티모달 감정 분석 완료"
   ```

## 관련 자료

- Firebase Gemini: [Multimodal capabilities](https://firebase.google.com/docs/vertex-ai/gemini-api#multimodal_input)
- Apple: [AVAudioEngine](https://developer.apple.com/documentation/avfaudio/avaudioengine)
- 관련 파일:
  - `Mentory/Service/Microphone/AudioEngine.swift`
  - `Mentory/Adapter/FirebaseLLM/FirebaseLLM.swift`
  - `Values/MentoryiOS/MentoryCharacter.swift`
