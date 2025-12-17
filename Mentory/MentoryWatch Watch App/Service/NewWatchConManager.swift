//
//  NewWatchConManager.swift
//  Mentory
//
//  Created by 김민우 on 12/17/25.
//
import Foundation
import OSLog
import WatchConnectivity


// MARK: Object
@MainActor @Observable
final class NewWatchConManager: Sendable {
    // MARK: core
    static let shared = NewWatchConManager()
    
    
    // MARK: state
    private let logger = Logger()
    private let session: WCSession = .default
    
    var mentorMessage: String? = nil // 멘토 메시지를 불러오는 중...
    var mentorCharacter: String? = nil
    var actionTodos: [String] = []
    var todoCompletionStatus: [Bool] = []
    
    var connectionStatus: String? = nil // 연결 대기 중
    
    private var isSetUp: Bool = false
    private var handler: HandlerSet? = nil
    
    
    // MARK: action
    func setUp() {
        // capture
        guard handler == nil else {
            logger.error("이미 세팅된 상태입니다.")
            return
        }
        
        guard WCSession.isSupported() else {
            logger.error("WCSession이 지원되지 않는 기기입니다.")
            return
        }
        
        // process
        let handler = HandlerSet { status in
            
        } updateHandler: { [weak self] watchData in
            Task { @MainActor in
                self?.mentorMessage = watchData.mentorMessage
                self?.mentorCharacter = watchData.mentorCharacter
                self?.actionTodos = watchData.actionTodos
                self?.todoCompletionStatus = watchData.todoCompletionStatus
                self?.connectionStatus = watchData.connectionStatus
            }
        }
        
        session.delegate = handler
        session.activate()
        
        // mutate
        self.handler = handler
    }
    
    func loadContext() {
        // capture
        guard let handler else {
            logger.error("Handler가 등록되어 있지 않습니다.")
            return
        }
        
        // process
        let context = session.receivedApplicationContext
        let mentorMsg = context["mentorMessage"] as? String ?? ""
        let character = context["mentorCharacter"] as? String ?? ""
        let todos = context["actionTodos"] as? [String] ?? []
        let completionStatus = context["todoCompletionStatus"] as? [Bool] ?? []

        logger.debug("ApplicationContext에서 데이터 로드 완료")
        
        let data = WatchData(
            mentorMessage: mentorMsg,
            mentorCharacter: character,
            actionTodos: todos,
            todoCompletionStatus: completionStatus,
            connectionStatus: "연결됨"
        )

        handler.updateHandler(data)
    }
    func updateContext() {
        // capture
        let message = self.mentorMessage ?? ""
        let character = self.mentorCharacter ?? ""
        let todos = self.actionTodos
        let todoCompletions = self.todoCompletionStatus
        
        // process
        let context: [String: Any] = [
            "mentorMessage": message,
            "mentorCharacter": character,
            "actionTodos": todos,
            "todoCompletionStatus": todoCompletions,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        do {
            try session.updateApplicationContext(context)
            logger.debug("iOS으로 데이터 전송 성공")
        } catch {
            logger.error("iOS으로 데이터 전송 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: value
    typealias StateHandler = @Sendable (String) -> Void
    typealias UpdateHandler = @Sendable (WatchData) -> Void
    
    struct WatchData: Sendable, Hashable {
        let mentorMessage: String
        let mentorCharacter: String
        let actionTodos: [String]
        let todoCompletionStatus: [Bool]
        let connectionStatus: String
    }
    
    nonisolated final class HandlerSet: NSObject, WCSessionDelegate {
        private let logger = Logger()
        let stateHandler: StateHandler
        let updateHandler: UpdateHandler
        init(stateHandler: @escaping StateHandler, updateHandler: @escaping UpdateHandler) {
            self.stateHandler = stateHandler
            self.updateHandler = updateHandler
        }
        
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
            // ConnectionStatus 업데이트
            let statusMessage: String

            switch activationState {
            case .activated:
                statusMessage = "활성화됨"
            case .inactive:
                statusMessage = "비활성화됨"
            case .notActivated:
                statusMessage = "활성화 안됨"
            @unknown default:
                statusMessage = "알 수 없는 상태"
            }

            if let error {
                logger.error("WCSession 활성화 오류: \(error.localizedDescription)")
                stateHandler("오류: \(error.localizedDescription)")
            } else {
                stateHandler(statusMessage)
            }
        }
        
        func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            let mentorMsg = message["mentorMessage"] as! String
            let character = message["mentorCharacter"] as! String
            let todos = message["actionTodos"] as! [String]
            let completionStatus = message["todoCompletionStatus"] as! [Bool]
            
            let data = WatchData(
                mentorMessage: mentorMsg,
                mentorCharacter: character,
                actionTodos: todos,
                todoCompletionStatus: completionStatus,
                connectionStatus: "연결됨"
            )
            
            updateHandler(data)
        }
        
        func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
            let mentorMsg = applicationContext["mentorMessage"] as! String
            let character = applicationContext["mentorCharacter"] as! String
            let todos = applicationContext["actionTodos"] as! [String]
            let completionStatus = applicationContext["todoCompletionStatus"] as! [Bool]
            
            let data = WatchData(
                mentorMessage: mentorMsg,
                mentorCharacter: character,
                actionTodos: todos,
                todoCompletionStatus: completionStatus,
                connectionStatus: "연결됨"
            )
            
            updateHandler(data)
        }
    }
}
