# 2025-12-03 WatchConnectivity Manager-Engine 분리 리팩토링

## 이슈 개요

- **배경**: `nonisolated(unsafe)` 방식으로 동시성 문제는 해결했지만, 구조적 문제 잔존
- **목표**: Manager-Engine 분리 패턴과 Actor를 활용한 근본적인 아키텍처 개선
- **영향 범위**: iOS 및 watchOS WatchConnectivity 전체 구조

## 기존 방식의 문제점

### 1. nonisolated(unsafe) 남용

```swift
// ❌ 기존 방식 (20251202 해결책)
@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    @Published var todayString: String = ""
    @Published var mentorMessage: String = ""

    // ⚠️ unsafe 키워드 남용
    nonisolated(unsafe) private var todayString: String = ""
    nonisolated(unsafe) private var mentorMessage: String = ""
    nonisolated(unsafe) private var mentorCharacter: String = ""
}
```

**문제점:**
- Swift의 동시성 안전 검증을 우회 (`unsafe`)
- 여러 변수를 `unsafe`로 선언하여 관리 복잡도 증가
- 컴파일러의 도움 없이 개발자가 수동으로 안전성 보장 필요

### 2. 단일 책임 원칙(SRP) 위반

```swift
// ❌ 150줄 이상의 단일 클래스
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    // 1. UI 상태 관리
    @Published var isPaired: Bool = false
    @Published var isReachable: Bool = false

    // 2. 데이터 캐시
    nonisolated(unsafe) private var mentorMessage: String = ""

    // 3. WCSession 관리
    private let session = WCSession.default

    // 4. 메시지 전송
    func sendDataToWatch() { ... }

    // 5. Delegate 처리
    nonisolated func session(_ session: WCSession, didReceiveMessage...) { ... }
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) { ... }
}
```

**문제점:**
- 하나의 클래스가 5가지 책임을 가짐
- 테스트하기 어려움
- 코드 변경 시 영향 범위가 넓음

### 3. 테스트 어려움

```swift
// ❌ WCSession과 강하게 결합
class WatchConnectivityManager {
    private let session = WCSession.default  // Mock 불가능

    func sendMessage() {
        session.sendMessage(...)  // 테스트 시 실제 WCSession 필요
    }
}
```

**문제점:**
- `WCSession.default`와 강하게 결합
- 유닛 테스트를 위한 Mock 객체 주입 불가능
- 통합 테스트만 가능 (실제 기기 필요)

### 4. 수동 스레드 관리

```swift
// ❌ 매번 수동으로 메인 스레드 전환
nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    self.cachedData = message["data"]  // nonisolated(unsafe) 접근

    // 수동으로 메인 스레드 전환
    Task { @MainActor in
        self.publishedData = self.cachedData
    }
}
```

**문제점:**
- `Task { @MainActor in }` 패턴을 매번 수동 작성
- 실수로 메인 스레드 전환을 빠뜨릴 위험
- 보일러플레이트 코드 증가

## 해결 방법: Manager-Engine 분리 패턴

### 아키텍처 설계

```
Before (nonisolated(unsafe) 방식):
┌─────────────────────────────────────────┐
│  WatchConnectivityManager               │  @MainActor
│  - @Published 상태                      │
│  - nonisolated(unsafe) 캐시             │
│  - WCSessionDelegate 구현               │
│  - nonisolated delegate 메서드          │
│  (150줄)                                │
└─────────────────────────────────────────┘

After (Manager-Engine 분리):
┌─────────────────────────────────┐
│  WatchConnectivityManager       │  @MainActor
│  - @Published 상태만 관리       │  UI Layer
│  - setUp() async                │  (50줄)
└────────────┬────────────────────┘
             │ Handler Callback
             │ (@Sendable 클로저)
             ↓
┌─────────────────────────────────┐
│  WatchConnectivityEngine        │  actor
│  - WCSessionDelegate 구현       │  Background Layer
│  - WCSession 관리               │  (150줄)
│  - 스레드 안전성 자동 보장      │
└─────────────────────────────────┘
```

### 핵심 설계 원칙

1. **관심사의 분리 (Separation of Concerns)**:
   - **Manager**: UI 레이어와 통신, SwiftUI에서 관찰 가능한 상태만 관리
   - **Engine**: WCSession 처리, 모든 백그라운드 로직 집중

2. **Actor를 사용한 자동 격리**:
   - Engine을 `actor`로 구현하여 컴파일러가 자동으로 스레드 안전성 보장
   - `nonisolated(unsafe)` 완전 제거

3. **Handler 기반 통신**:
   - Engine → Manager 데이터 전달은 `@Sendable` 클로저 사용
   - 타입 안전성과 스레드 안전성 동시 보장

4. **비동기 초기화**:
   - `setUp()` 메서드를 `async`로 구현
   - 핸들러 설정 → 엔진 활성화 순서 보장

## iOS 구현

### WatchConnectivityManager (iOS)

```swift
import Foundation
import Combine

/// iOS 앱에서 Watch 앱과 통신하기 위한 매니저
@MainActor
final class WatchConnectivityManager: ObservableObject {
    // MARK: - Core
    static let shared = WatchConnectivityManager()

    // MARK: - State (UI용 @Published만)
    @Published var isPaired: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var isReachable: Bool = false

    private var engine: WatchConnectivityEngine? = nil

    // MARK: - Initialization
    private init() { }

    // MARK: - Public Methods

    /// 엔진 설정 및 활성화
    func setUp() async {
        // 중복 설정 방지
        guard engine == nil else { return }

        let engine = WatchConnectivityEngine.shared

        // 1. 상태 업데이트 핸들러 설정
        await engine.setStateUpdateHandler { [weak self] state in
            Task { @MainActor in
                self?.isPaired = state.isPaired
                self?.isWatchAppInstalled = state.isWatchAppInstalled
                self?.isReachable = state.isReachable
            }
        }

        // 2. 엔진 활성화
        await engine.activate()

        // 3. 엔진 저장
        self.engine = engine
    }

    /// 멘토 메시지를 Watch로 전송
    func updateMentorMessage(_ message: String, character: String) async {
        await engine?.sendMentorMessage(message, character: character)
    }
}
```

**개선 사항:**
- ✅ `@Published` 속성만 관리 (UI 상태)
- ✅ WCSessionDelegate 관련 코드 완전 제거
- ✅ 약 50줄로 간결화
- ✅ `nonisolated(unsafe)` 사용 없음

### WatchConnectivityEngine (iOS)

```swift
import Foundation
@preconcurrency import WatchConnectivity
import OSLog

/// WCSessionDelegate를 구현하는 백그라운드 처리 전용 액터
actor WatchConnectivityEngine: NSObject {
    // MARK: - Core
    static let shared = WatchConnectivityEngine()

    private nonisolated let logger = Logger(subsystem: "Mentory.WatchConnectivityEngine", category: "Service")
    private nonisolated let session: WCSession

    // MARK: - State (actor가 자동으로 격리)
    private var cachedMentorMessage: String = ""
    private var cachedMentorCharacter: String = ""
    private var cachedIsPaired: Bool = false
    private var cachedIsWatchAppInstalled: Bool = false
    private var cachedIsReachable: Bool = false

    // MARK: - Handler
    private var stateUpdateHandler: StateUpdateHandler?
    typealias StateUpdateHandler = @Sendable (ConnectionState) -> Void

    // MARK: - Initialization
    private override init() {
        self.session = WCSession.default
    }

    // MARK: - Public Methods

    /// 엔진 활성화 (WCSession delegate 설정 및 activate)
    nonisolated func activate() {
        guard WCSession.isSupported() else {
            logger.error("WCSession이 지원되지 않는 기기입니다.")
            return
        }

        session.delegate = self
        session.activate()
    }

    /// 상태 업데이트 핸들러 설정
    func setStateUpdateHandler(_ handler: @escaping StateUpdateHandler) {
        self.stateUpdateHandler = handler
    }

    /// 멘토 메시지를 Watch로 전송
    func sendMentorMessage(_ message: String, character: String) {
        guard session.activationState == .activated else {
            logger.warning("WCSession이 활성화되지 않음")
            return
        }

        // 캐시 업데이트
        cachedMentorMessage = message
        cachedMentorCharacter = character

        // Application Context로 전송 (최신 상태만 유지)
        let context: [String: Any] = [
            "mentorMessage": message,
            "mentorCharacter": character,
            "timestamp": Date().timeIntervalSince1970
        ]

        do {
            try session.updateApplicationContext(context)
            logger.debug("Watch로 데이터 전송 성공")
        } catch {
            logger.error("Watch로 데이터 전송 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Internal Methods

    /// 활성화 상태 업데이트
    func handleActivation(state: WCSessionActivationState, session: WCSession, error: Error?) {
        cachedIsPaired = session.isPaired
        cachedIsWatchAppInstalled = session.isWatchAppInstalled
        cachedIsReachable = session.isReachable

        if let error = error {
            logger.error("WCSession 활성화 오류: \(error.localizedDescription)")
        } else {
            logger.debug("WCSession 활성화 완료")

            // 활성화 완료 시 캐시된 데이터가 있으면 전송
            if !cachedMentorMessage.isEmpty {
                sendMentorMessage(cachedMentorMessage, character: cachedMentorCharacter)
            }
        }

        notifyStateUpdate()
    }

    /// Reachability 변경 처리
    func handleReachabilityChange(isReachable: Bool) {
        cachedIsReachable = isReachable
        notifyStateUpdate()
    }

    // MARK: - Private Methods

    /// 핸들러를 통해 상태 변경 알림
    private func notifyStateUpdate() {
        let state = ConnectionState(
            isPaired: cachedIsPaired,
            isWatchAppInstalled: cachedIsWatchAppInstalled,
            isReachable: cachedIsReachable
        )

        stateUpdateHandler?(state)
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityEngine: @preconcurrency WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task {
            await handleActivation(state: activationState, session: session, error: error)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        // iOS 전용: Watch가 새로운 기기로 전환 중
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // iOS 전용: Watch 전환 완료, 재활성화 필요
        session.activate()
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task {
            await handleReachabilityChange(isReachable: session.isReachable)
        }
    }
}

// MARK: - Data Model
struct ConnectionState: Sendable {
    let isPaired: Bool
    let isWatchAppInstalled: Bool
    let isReachable: Bool
}
```

**개선 사항:**
- ✅ `actor`로 구현하여 모든 상태 변수 자동 격리
- ✅ `nonisolated(unsafe)` 완전 제거
- ✅ `Task { await }`로 delegate → actor 메서드 호출
- ✅ 모든 백그라운드 로직 집중

## watchOS 구현

### WatchConnectivityManager (watchOS)

```swift
import Foundation
import Combine

/// WatchOS에서 iOS 앱과 통신하기 위한 매니저
@MainActor
final class WatchConnectivityManager: ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var mentorMessage: String = "멘토 메시지를 불러오는 중..."
    @Published var mentorCharacter: String = ""
    @Published var connectionStatus: String = "연결 대기 중"

    private var engine: WatchConnectivityEngine? = nil

    private init() { }

    func setUp() async {
        guard engine == nil else { return }

        let engine = WatchConnectivityEngine.shared

        await engine.setDataUpdateHandler { [weak self] data in
            Task { @MainActor in
                self?.mentorMessage = data.mentorMessage
                self?.mentorCharacter = data.mentorCharacter
                self?.connectionStatus = data.connectionStatus
            }
        }

        await engine.activate()

        self.engine = engine
    }

    func loadInitialData() {
        engine?.loadInitialDataFromContext()
    }
}
```

### WatchConnectivityEngine (watchOS)

```swift
import Foundation
@preconcurrency import WatchConnectivity
import OSLog

actor WatchConnectivityEngine: NSObject {
    static let shared = WatchConnectivityEngine()

    private nonisolated let logger = Logger(subsystem: "MentoryWatch.WatchConnectivityEngine", category: "Service")
    private let session: WCSession

    private var cachedMentorMessage: String = ""
    private var cachedMentorCharacter: String = ""
    private var cachedConnectionStatus: String = "연결 대기 중"

    private var dataUpdateHandler: DataUpdateHandler?
    typealias DataUpdateHandler = @Sendable (WatchData) -> Void

    private override init() {
        self.session = WCSession.default
    }

    func activate() {
        guard WCSession.isSupported() else {
            logger.error("WCSession이 지원되지 않는 기기입니다.")
            return
        }

        session.delegate = self
        session.activate()
    }

    func setDataUpdateHandler(_ handler: @escaping DataUpdateHandler) {
        self.dataUpdateHandler = handler
    }

    func loadInitialDataFromContext() {
        let context = session.receivedApplicationContext
        let mentorMsg = context["mentorMessage"] as? String ?? ""
        let character = context["mentorCharacter"] as? String ?? ""

        logger.debug("ApplicationContext에서 데이터 로드 완료")
        handleReceivedData(mentorMsg: mentorMsg, character: character)
    }

    func handleReceivedData(mentorMsg: String?, character: String?) {
        if let mentorMsg = mentorMsg {
            cachedMentorMessage = mentorMsg
        }
        if let character = character {
            cachedMentorCharacter = character
        }

        updateConnectionStatus("연결됨")
        notifyDataUpdate()
    }

    func handleActivation(state: WCSessionActivationState, error: Error?) {
        let statusMessage: String

        switch state {
        case .activated:
            statusMessage = "활성화됨"
            loadInitialDataFromContext()
        case .inactive:
            statusMessage = "비활성화됨"
        case .notActivated:
            statusMessage = "활성화 안됨"
        @unknown default:
            statusMessage = "알 수 없는 상태"
        }

        if let error = error {
            logger.error("WCSession 활성화 오류: \(error.localizedDescription)")
            updateConnectionStatus("오류: \(error.localizedDescription)")
        } else {
            updateConnectionStatus(statusMessage)
        }
    }

    private func updateConnectionStatus(_ status: String) {
        cachedConnectionStatus = status
        notifyDataUpdate()
    }

    private func notifyDataUpdate() {
        let data = WatchData(
            mentorMessage: cachedMentorMessage,
            mentorCharacter: cachedMentorCharacter,
            connectionStatus: cachedConnectionStatus
        )

        dataUpdateHandler?(data)
    }
}

extension WatchConnectivityEngine: @preconcurrency WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task {
            await handleActivation(state: activationState, error: error)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let mentorMsg = message["mentorMessage"] as? String
        let character = message["mentorCharacter"] as? String

        Task {
            await handleReceivedData(mentorMsg: mentorMsg, character: character)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        let mentorMsg = applicationContext["mentorMessage"] as? String
        let character = applicationContext["mentorCharacter"] as? String

        Task {
            await handleReceivedData(mentorMsg: mentorMsg, character: character)
        }
    }
}

struct WatchData: Sendable {
    let mentorMessage: String
    let mentorCharacter: String
    let connectionStatus: String
}
```

## 앱에서 사용하기

```swift
// iOS/watchOS 모두 동일한 패턴
import SwiftUI

@main
struct MentoryApp: App {
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // 앱 시작 시 비동기로 WatchConnectivity 설정
                    await watchConnectivity.setUp()
                }
        }
    }
}
```

## 개선 사항 비교

### 1. nonisolated(unsafe) 제거

**Before:**
```swift
@MainActor
class WatchConnectivityManager {
    @Published var mentorMessage: String = ""
    nonisolated(unsafe) private var mentorMessage: String = ""  // ⚠️ unsafe
    nonisolated(unsafe) private var mentorCharacter: String = ""  // ⚠️ unsafe
}
```

**After:**
```swift
@MainActor
class WatchConnectivityManager {
    @Published var isPaired: Bool = false  // ✅ UI용만
}

actor WatchConnectivityEngine {
    private var cachedMentorMessage: String = ""  // ✅ actor가 자동으로 격리
    private var cachedMentorCharacter: String = ""  // ✅ 안전 보장
}
```

### 2. 스레드 관리 자동화

**Before:**
```swift
nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    // 1. unsafe 변수 직접 수정
    self.cachedData = message["data"]

    // 2. 수동으로 메인 스레드 전환
    Task { @MainActor in
        self.publishedData = self.cachedData
    }
}
```

**After:**
```swift
nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    // actor 메서드가 자동으로 스레드 안전성 보장
    Task {
        await handleReceivedData(message: message)  // ✅ actor가 격리 관리
    }
}
```

### 3. 코드 라인 수 감소

| 파일 | Before | After |
|------|--------|-------|
| WatchConnectivityManager | 150줄 | 50줄 |
| WatchConnectivityEngine | 없음 | 150줄 |
| **합계** | **150줄** | **200줄** |

*라인 수는 증가했지만, 각 파일의 책임이 명확하고 테스트/유지보수 용이*

### 4. 단일 책임 원칙 준수

**Before:**
- 1개 클래스 → 5가지 책임

**After:**
- `WatchConnectivityManager` → 1가지 책임 (UI 상태 관리)
- `WatchConnectivityEngine` → 1가지 책임 (WCSession 처리)

### 5. 테스트 가능성

**Before:**
```swift
class WatchConnectivityManager {
    private let session = WCSession.default  // Mock 불가능
}
```

**After:**
```swift
// Protocol로 추상화 가능
protocol WatchConnectivityEngineProtocol {
    func activate() async
    func sendMentorMessage(_ message: String, character: String) async
}

class WatchConnectivityManager {
    private var engine: WatchConnectivityEngineProtocol?  // Mock 가능
}
```

## 핵심 패턴 정리

### 1. Actor를 사용한 자동 격리

```swift
// ✅ actor 내부의 모든 변수는 자동으로 격리됨
actor WatchConnectivityEngine {
    private var cachedData: String = ""  // nonisolated(unsafe) 불필요

    // actor 메서드는 자동으로 스레드 안전
    func updateData(_ data: String) {
        cachedData = data  // ✅ 안전
    }
}
```

**이점:**
- 컴파일러가 자동으로 스레드 안전성 검증
- `nonisolated(unsafe)` 불필요
- 실수로 인한 데이터 경쟁 불가능

### 2. nonisolated + Task 패턴

```swift
// WCSessionDelegate 메서드는 백그라운드에서 호출됨
nonisolated func session(_ session: WCSession, ...) {
    // Task로 감싸서 actor 메서드 호출
    Task {
        await handleActivation(...)  // actor가 스레드 안전성 보장
    }
}
```

**이점:**
- delegate 메서드를 `nonisolated`로 선언하여 백그라운드 호출 허용
- `await`를 통해 actor의 격리된 메서드 호출
- 스레드 전환이 자동으로 처리됨

### 3. Handler를 통한 안전한 데이터 전달

```swift
// Engine → Manager 데이터 전달
typealias StateUpdateHandler = @Sendable (ConnectionState) -> Void

func setStateUpdateHandler(_ handler: @escaping StateUpdateHandler) {
    self.stateUpdateHandler = handler
}

private func notifyStateUpdate() {
    let state = ConnectionState(...)  // Sendable 타입
    stateUpdateHandler?(state)  // ✅ 스레드 안전
}
```

**이점:**
- `@Sendable` 클로저로 스레드 간 안전한 데이터 전달
- 값 타입(struct)으로 데이터 전달하여 참조 공유 없음
- 타입 안전성 보장

### 4. 비동기 초기화 패턴

```swift
func setUp() async {
    let engine = WatchConnectivityEngine.shared

    // 1. 핸들러 설정
    await engine.setStateUpdateHandler { ... }

    // 2. 엔진 활성화
    await engine.activate()

    // 3. 엔진 저장
    self.engine = engine
}
```

**이점:**
- 초기화 순서가 명확하게 보장됨
- `async/await`를 통한 간결한 비동기 처리
- 콜백 지옥(callback hell) 방지

## 회고 및 예방

### 배운 점

1. **nonisolated(unsafe)는 임시 해결책**:
   - 긴급하게 동시성 문제를 해결할 수 있지만, 근본적인 해결책은 아님
   - Actor를 사용한 구조적 해결이 더 안전하고 유지보수 용이

2. **Actor는 단순한 스레드 안전성 이상**:
   - 코드 구조를 개선하도록 강제함
   - 명확한 책임 분리를 유도
   - 컴파일 타임에 동시성 버그 대부분 검출

3. **점진적 리팩토링의 중요성**:
   - 1단계: `nonisolated(unsafe)`로 긴급 수정 (12월 2일)
   - 2단계: Manager-Engine 분리로 구조 개선 (12월 3일)
   - 각 단계가 다음 단계의 토대가 됨

4. **Swift Concurrency의 진화**:
   - 처음엔 복잡해 보이지만, 올바르게 사용하면 코드가 더 단순해짐
   - `@MainActor`, `actor`, `nonisolated`를 조합하면 대부분의 동시성 문제 해결 가능

5. **테스트 가능한 설계의 부수 효과**:
   - 테스트를 위한 구조 개선이 전체 코드 품질 향상으로 이어짐
   - Protocol 추상화 → 의존성 주입 → 테스트 용이성 → 유지보수성 향상

### 향후 개선 사항

1. **Protocol 추상화**:
   ```swift
   protocol WatchConnectivityEngineProtocol {
       func activate() async
       func sendMentorMessage(_ message: String, character: String) async
       func setStateUpdateHandler(_ handler: @escaping (ConnectionState) -> Void) async
   }
   ```
   - 테스트를 위한 Mock Engine 구현 가능
   - 의존성 주입으로 결합도 감소

2. **에러 처리 강화**:
   ```swift
   enum WatchConnectivityError: Error {
       case sessionNotActivated
       case sessionNotSupported
       case dataTransferFailed(Error)
   }

   func sendMentorMessage(_ message: String) async throws {
       guard session.activationState == .activated else {
           throw WatchConnectivityError.sessionNotActivated
       }
       // ...
   }
   ```

3. **로깅 개선**:
   ```swift
   // OSLog를 활용한 구조화된 로깅
   logger.debug("Watch로 데이터 전송", metadata: [
       "message": "\(message)",
       "character": "\(character)",
       "timestamp": "\(Date())"
   ])
   ```

4. **유닛 테스트 작성**:
   ```swift
   class WatchConnectivityManagerTests: XCTestCase {
       func testSetUp() async {
           let manager = WatchConnectivityManager.shared
           await manager.setUp()
           // 테스트 로직
       }
   }
   ```

### 예방 조치

1. **새로운 기능 개발 시 체크리스트**:
   - [ ] 단일 책임 원칙을 준수하는가?
   - [ ] Actor를 사용하여 스레드 안전성을 보장하는가?
   - [ ] `nonisolated(unsafe)` 사용을 최소화했는가?
   - [ ] Protocol 추상화로 테스트 가능한가?

2. **코드 리뷰 포인트**:
   - `nonisolated(unsafe)` 사용 시 반드시 주석으로 안전한 이유 설명
   - 150줄 이상의 클래스는 분리 검토
   - `@MainActor` 클래스에서 WCSessionDelegate 직접 구현 금지

3. **문서화**:
   - 아키텍처 결정 사항은 트러블슈팅 문서에 기록
   - 리팩토링 이유와 Before/After 비교 포함

## 관련 자료

- 이전 트러블슈팅: [20251202-watchconnectivity.md](./20251202-watchconnectivity.md)
- Apple 공식 문서: [Actors](https://developer.apple.com/documentation/swift/actor)
- Swift Evolution: [SE-0306 Actors](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md)
- 프로젝트 커밋:
  - iOS Manager 리팩토링: [c00157f](https://github.com/EST-iOS4/Mentory/commit/c00157f)
  - 비동기 초기화: [63d2dce](https://github.com/EST-iOS4/Mentory/commit/63d2dce)
  - 엔진 활성화 비동기화: [f144572](https://github.com/EST-iOS4/Mentory/commit/f144572)
  - 엔진 데이터 로드 개선: [7fbd241](https://github.com/EST-iOS4/Mentory/commit/7fbd241)
  - nonisolated 제거: [f356947](https://github.com/EST-iOS4/Mentory/commit/f356947)
