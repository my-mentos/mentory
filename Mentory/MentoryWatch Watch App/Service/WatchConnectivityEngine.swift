//
//  WatchConnectivityEngine.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 12/2/25.
//

import Foundation
@preconcurrency import WatchConnectivity
import OSLog

/// WCSessionDelegate를 구현하는 백그라운드 처리 전용 액터
actor WatchConnectivityEngine: NSObject {
    // MARK: - Core
    static let shared = WatchConnectivityEngine()

    private nonisolated let logger = Logger(subsystem: "MentoryWatch.WatchConnectivityEngine", category: "Service")
    private let session: WCSession

    // MARK: - State
    private var cachedMentorMessage: String = ""
    private var cachedMentorCharacter: String = ""
    private var cachedActionTodos: [String] = []
    private var cachedTodoCompletionStatus: [Bool] = []
    private var cachedConnectionStatus: String = "연결 대기 중"

    // MARK: - Handler
    private var dataUpdateHandler: DataUpdateHandler?

    typealias DataUpdateHandler = @Sendable (WatchData) -> Void

    // MARK: - Initialization
    private override init() {
        self.session = WCSession.default
    }

    // MARK: - Public Methods

    /// 엔진 활성화 (WCSession delegate 설정 및 activate)
    func activate() {
        guard WCSession.isSupported() else {
            logger.error("WCSession이 지원되지 않는 기기입니다.")
            return
        }

        session.delegate = self
        session.activate()
    }

    /// 데이터 업데이트 핸들러 설정
    func setDataUpdateHandler(_ handler: @escaping DataUpdateHandler) {
        self.dataUpdateHandler = handler
    }

    /// iOS 앱에서 보낸 applicationContext 데이터 로드
    func loadInitialDataFromContext() {
        // iOS에서 updateApplicationContext로 보낸 최신 데이터 읽기
        let context = session.receivedApplicationContext
        let mentorMsg = context["mentorMessage"] as? String ?? ""
        let character = context["mentorCharacter"] as? String ?? ""
        let todos = context["actionTodos"] as? [String] ?? []
        let completionStatus = context["todoCompletionStatus"] as? [Bool] ?? []

        logger.debug("ApplicationContext에서 데이터 로드 완료")

        handleReceivedData(
            mentorMsg: mentorMsg,
            character: character,
            todos: todos,
            completionStatus: completionStatus
        )
    }

    // MARK: - Internal Methods

    /// 받은 데이터 처리
    func handleReceivedData(
        mentorMsg: String?,
        character: String?,
        todos: [String]? = nil,
        completionStatus: [Bool]? = nil
    ) {
        if let mentorMsg = mentorMsg {
            cachedMentorMessage = mentorMsg
        }
        if let character = character {
            cachedMentorCharacter = character
        }
        if let todos = todos {
            cachedActionTodos = todos
        }
        if let completionStatus = completionStatus {
            cachedTodoCompletionStatus = completionStatus
        }

        updateConnectionStatus("연결됨")
        notifyDataUpdate()
    }

    /// iPhone으로 투두 완료 처리 전송
    func sendTodoCompletion(todoText: String, isCompleted: Bool) {
        guard session.activationState == .activated else {
            logger.warning("WCSession이 활성화되지 않음")
            return
        }

        let message: [String: Any] = [
            "action": "todoCompletion",
            "todoText": todoText,
            "isCompleted": isCompleted
        ]

        session.sendMessage(message, replyHandler: nil) { error in
            self.logger.error("투두 완료 처리 전송 실패: \(error.localizedDescription)")
        }

        logger.debug("투두 완료 처리 전송: \(todoText) = \(isCompleted)")
    }

    /// 활성화 상태 업데이트
    func handleActivation(state: WCSessionActivationState, error: Error?) {
        let statusMessage: String

        switch state {
        case .activated:
            statusMessage = "활성화됨"
            // 활성화 완료되면 applicationContext에서 데이터 로드
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

    // MARK: - Private Methods

    /// 연결 상태 업데이트
    private func updateConnectionStatus(_ status: String) {
        cachedConnectionStatus = status
        notifyDataUpdate()
    }

    /// 핸들러를 통해 데이터 변경 알림
    private func notifyDataUpdate() {
        let data = WatchData(
            mentorMessage: cachedMentorMessage,
            mentorCharacter: cachedMentorCharacter,
            actionTodos: cachedActionTodos,
            todoCompletionStatus: cachedTodoCompletionStatus,
            connectionStatus: cachedConnectionStatus
        )

        dataUpdateHandler?(data)
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityEngine: @preconcurrency WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task {
            await handleActivation(state: activationState, error: error)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let mentorMsg = message["mentorMessage"] as? String
        let character = message["mentorCharacter"] as? String
        let todos = message["actionTodos"] as? [String]
        let completionStatus = message["todoCompletionStatus"] as? [Bool]

        Task {
            await handleReceivedData(
                mentorMsg: mentorMsg,
                character: character,
                todos: todos,
                completionStatus: completionStatus
            )
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let mentorMsg = applicationContext["mentorMessage"] as? String
        let character = applicationContext["mentorCharacter"] as? String
        let todos = applicationContext["actionTodos"] as? [String]
        let completionStatus = applicationContext["todoCompletionStatus"] as? [Bool]

        Task {
            await handleReceivedData(
                mentorMsg: mentorMsg,
                character: character,
                todos: todos,
                completionStatus: completionStatus
            )
        }
    }
}

// MARK: - Data Model
struct WatchData: Sendable {
    let mentorMessage: String
    let mentorCharacter: String
    let actionTodos: [String]
    let todoCompletionStatus: [Bool]
    let connectionStatus: String
}
