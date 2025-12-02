# WatchConnectivity

WatchConnectivity는 iOS 앱과 watchOS 앱 간의 양방향 통신을 가능하게 하는 프레임워크입니다.

## 주요 기능

- **실시간 메시지 전송**: 앱이 실행 중일 때 즉시 데이터 전송
- **백그라운드 데이터 전송**: 앱이 백그라운드에 있을 때도 데이터 전송
- **파일 전송**: 이미지나 문서 같은 파일 전송
- **애플리케이션 컨텍스트**: 최신 상태 정보 동기화

## Swift Concurrency 주의사항

WCSessionDelegate 메서드는 백그라운드 스레드에서 호출됩니다.
`@MainActor` 클래스에서 구현할 때는 반드시 `nonisolated`로 선언하세요.

## 기본 설정

### iOS 앱 설정

```swift
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    // 싱글톤 패턴으로 앱 전체에서 하나의 인스턴스만 사용
    static let shared = WatchConnectivityManager()
    
    // SwiftUI에서 관찰 가능한 속성
    @Published var receivedMessage: String = ""
    
    private override init() {
        super.init()
        
        // WatchConnectivity가 현재 디바이스에서 지원되는지 확인
        if WCSession.isSupported() {
            let session = WCSession.default
            // delegate 설정 (메시지 수신 등을 처리하기 위함)
            session.delegate = self
            // 세션 활성화
            session.activate()
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    // 세션 활성화 완료 시 호출되는 메서드
    // activationState: Activated, Inactive, NotActivated 중 하나
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    // iOS에서 Apple Watch를 다른 기기와 페어링할 때 호출
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }
    
    // 이전 세션이 비활성화될 때 호출 (새로운 Watch와 페어링 시)
    func sessionDidDeactivate(_ session: WCSession) {
        // 새로운 Watch와 통신하기 위해 세션 재활성화
        WCSession.default.activate()
    }
}
```

### watchOS 앱 설정

```swift
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var receivedMessage: String = ""
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    // watchOS에서는 sessionDidBecomeInactive와 sessionDidDeactivate가 호출되지 않음
    // (Watch는 항상 하나의 iPhone과만 페어링되므로)
}
```

## 메시지 전송 방법

### 1. 실시간 메시지 (Interactive Messaging)

**특징**: 양방향 통신, 즉각적인 응답, 양쪽 앱이 모두 실행 중이어야 함

```swift
// 메시지 보내기
func sendMessage(_ message: [String: Any]) {
    // isReachable: 상대방 앱이 현재 실행 중이고 통신 가능한지 확인
    guard WCSession.default.isReachable else {
        print("Watch is not reachable")
        return
    }
    
    // sendMessage: 딕셔너리 형태로 데이터 전송
    // replyHandler: 상대방으로부터 응답을 받았을 때 실행
    // errorHandler: 전송 실패 시 실행
    WCSession.default.sendMessage(message, replyHandler: { reply in
        print("Reply received: \(reply)")
    }, errorHandler: { error in
        print("Error sending message: \(error.localizedDescription)")
    })
}

// 메시지 받기
func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    // UI 업데이트는 메인 스레드에서 실행
    DispatchQueue.main.async {
        // 받은 메시지에서 데이터 추출
        if let text = message["text"] as? String {
            self.receivedMessage = text
        }
        
        // 송신자에게 응답 보내기
        // 이 응답은 송신자의 replyHandler에서 받게 됨
        replyHandler(["status": "received"])
    }
}
```

### 2. Application Context (최신 상태 동기화)

**특징**: 최신 데이터만 유지, 이전 데이터는 덮어씀, 백그라운드 전송 가능

```swift
// 컨텍스트 업데이트
func updateApplicationContext(_ context: [String: Any]) {
    do {
        // updateApplicationContext: 가장 최근 상태 정보를 전송
        // 이전에 보낸 데이터가 아직 전송 중이면 취소되고 새 데이터로 대체됨
        // 예: 설정 값, 현재 상태 등 "최신 값"만 중요한 경우에 사용
        try WCSession.default.updateApplicationContext(context)
        print("Context updated successfully")
    } catch {
        print("Error updating context: \(error.localizedDescription)")
    }
}

// 컨텍스트 받기
func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    DispatchQueue.main.async {
        // 받은 컨텍스트 데이터 처리
        if let count = applicationContext["stepCount"] as? Int {
            print("Step count updated: \(count)")
        }
    }
}
```

**사용 예시**:
```swift
// 설정 동기화
updateApplicationContext([
    "isDarkMode": true,
    "fontSize": 14,
    "unit": "metric"
])
```

### 3. User Info Transfer (백그라운드 전송)

**특징**: 모든 데이터가 큐에 저장되어 순차적으로 전송, 앱이 백그라운드에 있어도 전송됨

```swift
// User Info 전송
func transferUserInfo(_ userInfo: [String: Any]) {
    // transferUserInfo: FIFO 큐에 저장되어 순차적으로 전송
    // 모든 데이터가 중요하고 누락되면 안 되는 경우 사용
    // 예: 운동 기록, 건강 데이터 등
    WCSession.default.transferUserInfo(userInfo)
}

// User Info 받기
func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    DispatchQueue.main.async {
        print("Received user info: \(userInfo)")
        
        // 운동 데이터 예시
        if let workoutType = userInfo["workoutType"] as? String,
           let duration = userInfo["duration"] as? Double,
           let calories = userInfo["calories"] as? Int {
            // 데이터 저장 또는 처리
            print("Workout: \(workoutType), Duration: \(duration)min, Calories: \(calories)")
        }
    }
}
```

**사용 예시**:
```swift
// 운동 데이터 전송
transferUserInfo([
    "workoutType": "Running",
    "duration": 30.5,
    "calories": 250,
    "distance": 5.2,
    "timestamp": Date().timeIntervalSince1970
])
```

### 4. 파일 전송

**특징**: 큰 파일 전송에 적합, 백그라운드 전송, 메타데이터 포함 가능

```swift
// 파일 보내기
func transferFile(_ fileURL: URL, metadata: [String: Any]? = nil) {
    // transferFile: 이미지, 오디오, 문서 등의 파일 전송
    // metadata: 파일에 대한 추가 정보 (파일 이름, 타입, 설명 등)
    WCSession.default.transferFile(fileURL, metadata: metadata)
}

// 파일 받기
func session(_ session: WCSession, didReceive file: WCSessionFile) {
    DispatchQueue.main.async {
        print("Received file: \(file.fileURL)")
        print("Metadata: \(String(describing: file.metadata))")
        
        // 받은 파일은 임시 위치에 저장되므로 영구 저장소로 복사 필요
        if let metadata = file.metadata,
           let fileName = metadata["fileName"] as? String {
            // 파일을 Documents 디렉토리로 복사
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent(fileName)
            
            do {
                // 기존 파일이 있으면 삭제
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                // 파일 복사
                try FileManager.default.copyItem(at: file.fileURL, to: destinationURL)
                print("File saved to: \(destinationURL)")
            } catch {
                print("Error saving file: \(error)")
            }
        }
    }
}
```

**사용 예시**:
```swift
// 이미지 파일 전송
if let imageURL = saveImageToTemporaryDirectory(image: myImage) {
    transferFile(imageURL, metadata: [
        "fileName": "workout_photo.jpg",
        "type": "image",
        "date": Date().description
    ])
}
```

## SwiftUI 통합 예제

### iOS 앱

```swift
import SwiftUI

struct ContentView: View {
    // WatchConnectivityManager를 관찰하여 데이터 변경 시 UI 자동 업데이트
    @StateObject private var connectivity = WatchConnectivityManager.shared
    @State private var messageToSend = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("iOS App")
                .font(.headline)
            
            // 사용자 입력 받기
            TextField("Message", text: $messageToSend)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            // Watch로 메시지 전송
            Button("Send to Watch") {
                connectivity.sendMessage(["text": messageToSend])
            }
            .buttonStyle(.borderedProminent)
            
            // Watch로부터 받은 메시지 표시
            Text("Received from Watch:")
                .font(.caption)
            
            Text(connectivity.receivedMessage)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }
}
```

### watchOS 앱

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Watch App")
                .font(.headline)
            
            // iPhone으로 미리 정의된 메시지 전송
            Button("Send to iPhone") {
                connectivity.sendMessage(["text": "Hello from Watch!"])
            }
            
            // iPhone으로부터 받은 메시지 표시
            Text("Received:")
                .font(.caption)
            
            Text(connectivity.receivedMessage)
                .font(.caption2)
                .padding(5)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
        }
    }
}
```

## 완전한 WatchConnectivityManager 구현

```swift
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var receivedMessage: String = ""
    @Published var isReachable: Bool = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - 메시지 전송 메서드들
    
    // 실시간 메시지 전송 (앱이 실행 중일 때만)
    func sendMessage(_ message: [String: Any]) {
        guard WCSession.default.isReachable else {
            print("Counterpart app is not reachable")
            return
        }
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            print("Reply: \(reply)")
        }, errorHandler: { error in
            print("Error: \(error.localizedDescription)")
        })
    }
    
    // 컨텍스트 업데이트 (최신 상태만 전송)
    func updateContext(_ context: [String: Any]) {
        do {
            try WCSession.default.updateApplicationContext(context)
        } catch {
            print("Context update failed: \(error)")
        }
    }
    
    // User Info 전송 (모든 데이터 보장)
    func sendUserInfo(_ userInfo: [String: Any]) {
        WCSession.default.transferUserInfo(userInfo)
    }
    
    // 파일 전송
    func sendFile(_ url: URL, metadata: [String: Any]? = nil) {
        WCSession.default.transferFile(url, metadata: metadata)
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    // 연결 상태 변경 감지
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("Reachability changed: \(session.isReachable)")
        }
    }
    
    // 실시간 메시지 수신
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if let text = message["text"] as? String {
                self.receivedMessage = text
            }
            replyHandler(["status": "success"])
        }
    }
    
    // 컨텍스트 수신
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            print("Context received: \(applicationContext)")
        }
    }
    
    // User Info 수신
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            print("UserInfo received: \(userInfo)")
        }
    }
    
    // 파일 수신
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        DispatchQueue.main.async {
            print("File received: \(file.fileURL.lastPathComponent)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
```

## 연결 상태 확인

```swift
func checkConnectionStatus() {
    let session = WCSession.default
    
    // WatchConnectivity 지원 여부 (기본적으로 iPhone과 Watch에서는 true)
    print("isSupported: \(WCSession.isSupported())")
    
    // iPhone과 Watch가 페어링되어 있는지
    print("isPaired: \(session.isPaired)")
    
    // Watch에 앱이 설치되어 있는지
    print("isWatchAppInstalled: \(session.isWatchAppInstalled)")
    
    // 상대방 앱이 현재 실행 중이고 통신 가능한지 (실시간 메시지용)
    print("isReachable: \(session.isReachable)")
    
    // 세션 활성화 상태 (0: NotActivated, 1: Inactive, 2: Activated)
    print("activationState: \(session.activationState.rawValue)")
}
```

## 각 전송 방식 비교표

| 방식 | 즉시 전송 | 백그라운드 | 데이터 보장 | 사용 사례 |
|------|---------|-----------|-----------|----------|
| `sendMessage` | ✅ | ❌ | ❌ | 실시간 채팅, 즉각적인 명령 |
| `updateApplicationContext` | ❌ | ✅ | ❌ (최신만) | 설정 동기화, 현재 상태 |
| `transferUserInfo` | ❌ | ✅ | ✅ | 운동 기록, 건강 데이터 |
| `transferFile` | ❌ | ✅ | ✅ | 이미지, 오디오 파일 |

## 주의사항

1. **sendMessage 사용 시**
   - 반드시 `isReachable`을 확인해야 함
   - 상대방 앱이 실행 중이지 않으면 실패
   - 타임아웃이 있으므로 응답이 느린 작업에는 부적합

2. **updateApplicationContext 사용 시**
   - 이전 컨텍스트는 자동으로 덮어씌워짐
   - 모든 데이터를 보존해야 한다면 `transferUserInfo` 사용

3. **메모리 관리**
   - `WCSessionDelegate`를 구현할 때 `weak self` 사용 고려
   - 큰 파일 전송 시 메모리 사용량 주의

4. **iOS 전용 메서드**
   - `sessionDidBecomeInactive`와 `sessionDidDeactivate`는 iOS에서만 호출됨
   - watchOS에서는 구현하지 않아도 됨

5. **디버깅 팁**
   - 실제 기기에서 테스트 (시뮬레이터는 제한적)
   - Xcode의 Device & Simulators에서 Watch 로그 확인
   - `print` 문 또는 OSLog로 각 단계 추적