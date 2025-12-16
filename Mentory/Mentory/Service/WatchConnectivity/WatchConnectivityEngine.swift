//
//  WatchConnectivityEngine.swift
//  Mentory
//
//  Created by 구현모 on 12/2/25.
//
import Foundation
@preconcurrency import WatchConnectivity
import OSLog


// MARK: Object
actor WatchConnectivityEngine: NSObject {
    // MARK: core
    static let shared = WatchConnectivityEngine()

    private nonisolated let logger = Logger()
    private nonisolated let session: WCSession

    // MARK: - State
    private var cachedMentorMessage: String = ""
    private var cachedMentorCharacter: String = ""
    private var cachedActionTodos: [String] = []
    private var cachedTodoCompletionStatus: [Bool] = []
    private var cachedIsPaired: Bool = false
    private var cachedIsWatchAppInstalled: Bool = false
    private var cachedIsReachable: Bool = false

    // MARK: - Handler
    private var stateUpdateHandler: StateUpdateHandler?
    func setStateUpdateHandler(_ handler: @escaping StateUpdateHandler) {
        self.stateUpdateHandler = handler
    }
    
    private var todoCompletionHandler: TodoCompletionHandler?
    func setTodoCompletionHandler(_ handler: @escaping TodoCompletionHandler) {
        self.todoCompletionHandler = handler
    }


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

    /// 멘토 메시지를 Watch로 전송
    func sendMentorMessage(_ message: String, character: String) {
        guard session.activationState == .activated else {
            logger.warning("WCSession이 활성화되지 않음")
            return
        }

        cachedMentorMessage = message
        cachedMentorCharacter = character

        sendAllDataToWatch()
    }

    /// 행동 추천 투두를 Watch로 전송
    func sendActionTodos(_ todos: [String], completionStatus: [Bool]) {
        guard session.activationState == .activated else {
            logger.warning("WCSession이 활성화되지 않음")
            return
        }

        cachedActionTodos = todos
        cachedTodoCompletionStatus = completionStatus

        sendAllDataToWatch()
    }

    /// 모든 캐시된 데이터를 Watch로 전송
    private func sendAllDataToWatch() {
        guard session.activationState == .activated else {
            logger.warning("WCSession이 활성화되지 않음")
            return
        }

        let context: [String: Any] = [
            "mentorMessage": cachedMentorMessage,
            "mentorCharacter": cachedMentorCharacter,
            "actionTodos": cachedActionTodos,
            "todoCompletionStatus": cachedTodoCompletionStatus,
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
            // 활성화 완료 시 현재 데이터 전송
            if !cachedMentorMessage.isEmpty || !cachedActionTodos.isEmpty {
                sendAllDataToWatch()
            }
        }

        notifyStateUpdate()
    }

    /// Watch로부터 메시지 요청 처리 - 캐시된 데이터 반환
    func getCachedData() -> CachedData {
        return CachedData(
            mentorMessage: cachedMentorMessage,
            mentorCharacter: cachedMentorCharacter
        )
    }

    /// Reachability 변경 처리
    func handleReachabilityChange(isReachable: Bool) {
        cachedIsReachable = isReachable
        notifyStateUpdate()
    }

    /// Watch로부터 받은 투두 완료 처리
    func handleTodoCompletion(todoText: String, isCompleted: Bool) {
        // 로컬 캐시 업데이트
        guard let index = cachedActionTodos.firstIndex(of: todoText) else {
            logger.error("투두를 찾을 수 없음: \(todoText)")
            return
        }

        cachedTodoCompletionStatus[index] = isCompleted
        logger.debug("투두 완료 상태 업데이트: todoText=\(todoText), isCompleted=\(isCompleted)")

        // 핸들러를 통해 TodayBoard로 전달
        todoCompletionHandler?(todoText, isCompleted)

        // 업데이트된 상태를 Watch로 다시 전송하여 동기화 유지
        sendAllDataToWatch()
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
    
    
    // MARK: value
    typealias StateUpdateHandler = @Sendable (ConnectionState) -> Void
    typealias TodoCompletionHandler = @Sendable (String, Bool) -> Void
    
    struct ConnectionState: Sendable, Hashable {
        let isPaired: Bool
        let isWatchAppInstalled: Bool
        let isReachable: Bool
    }

    struct CachedData: Sendable, Hashable {
        let mentorMessage: String
        let mentorCharacter: String
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityEngine: @preconcurrency WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
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

    /// Watch로부터 메시지 수신 (투두 완료 처리)
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let action = message["action"] as? String,
              action == "todoCompletion",
              let todoText = message["todoText"] as? String,
              let isCompleted = message["isCompleted"] as? Bool else {
            return
        }

        Task {
            await handleTodoCompletion(todoText: todoText, isCompleted: isCompleted)
        }
    }

}
