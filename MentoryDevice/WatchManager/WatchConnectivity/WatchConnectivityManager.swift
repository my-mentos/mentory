//
//  WatchConnectivityManager.swift
//  Mentory
//
//  Created by 구현모 on 11/26/25.
//
import Foundation
import Combine
import OSLog
import Observation
import WatchConnectivity



// MARK: Object
@MainActor @Observable
public final class WatchConnectivityManager: WatchConnectivityInterface {
    // MARK: core
    private let logger = Logger()
    public static let shared = WatchConnectivityManager()
    private init() { }

    // MARK: state
    public var message: String? = nil
    public var character: String? = nil
    public var todos: [String] = []
    public var todoCompletions: [Bool] = []
    
    private(set) var isPaired: Bool = false
    private(set) var isWatchAppInstalled: Bool = false
    private(set) var isReachable: Bool = false

    private var session: WCSession = .default
    public var handlers: HandlerSet? = nil
    


    // MARK: action
    public func configureTodoHandler(_ handler: @escaping WatchTodoHandler) {
        self.handlers = HandlerSet(todoHandler: handler)
    }
    
    public func setUp() async {
        // capture
        guard let handlers else {
            logger.error("Handler가 설정되지 않았습니다.")
            return
        }
        guard WCSession.isSupported() else {
            logger.error("WCSession.isSupported()가 false입니다.")
            return
        }
        
        // process
        let newHandlers = handlers.with { [weak self] state in
            Task { @MainActor in
                self?.isPaired = state.isPaired
                self?.isWatchAppInstalled = state.isWatchAppInstalled
                self?.isReachable = state.isReachable
            }
        }
        
        session.delegate = newHandlers
        session.activate()
        
        // mutate
        self.handlers = newHandlers
        
        logger.debug("WatchConnectivityManager 설정 완료")
    }
    
    public func updateContext(
        message: String?,
        character: String?,
        todos: [String],
        todoCompletions: [Bool]
    ) async {
        self.message = message
        self.character = character
        self.todos = todos
        self.todoCompletions = todoCompletions
        
        // capture
        let message = self.message ?? ""
        let character = self.character ?? ""
        let todos = self.todos
        let todoCompletions = self.todoCompletions
        
        logger.debug("message: \(message), character: \(character)")
        logger.debug("todos: \(todos), todoCompletions: \(todoCompletions)")
        
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
            logger.debug("Watch로 데이터 전송 성공")
        } catch {
            logger.error("Watch로 데이터 전송 실패: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: value
    public typealias StateHandler = @Sendable (ConnectionState) -> Void
    public typealias TodoHandler = @Sendable (String, Bool) -> Void
    
    public struct ConnectionState: Sendable, Hashable {
        public let isPaired: Bool
        public let isWatchAppInstalled: Bool
        public let isReachable: Bool
    }
    
    public final nonisolated class HandlerSet: NSObject, WCSessionDelegate {
        // MARK: core
        private let logger = Logger()
        let activateHandler: StateHandler?
        let todoHandler: TodoHandler
        
        private init(activateHandler: StateHandler?, todoHandler: @escaping TodoHandler) {
            self.activateHandler = activateHandler
            self.todoHandler = todoHandler
        }
        public convenience init(todoHandler: @escaping TodoHandler) {
            self.init(activateHandler: nil, todoHandler: todoHandler)
        }
        
        // MARK: operator
        fileprivate func with(_ handler: @escaping StateHandler) -> HandlerSet {
            return HandlerSet(activateHandler: handler, todoHandler: self.todoHandler)
        }
        
        
        public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
            let connectionState = ConnectionState(
                isPaired: session.isPaired,
                isWatchAppInstalled: session.isWatchAppInstalled,
                isReachable: session.isReachable
            )
            
            activateHandler?(connectionState)
        }
        
        public func sessionDidBecomeInactive(_ session: WCSession) {
            // Watch가 새로운 기기로 전환하는 중
        }
        
        public func sessionDidDeactivate(_ session: WCSession) {
            // Watch가 전환 완료
            session.activate()
        }
        
        public func sessionReachabilityDidChange(_ session: WCSession) {
            let connectionState = ConnectionState(
                isPaired: session.isPaired,
                isWatchAppInstalled: session.isWatchAppInstalled,
                isReachable: session.isReachable
            )
            
            activateHandler?(connectionState)
        }
        
        public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            guard let action = message["action"] as? String,
                  action == "todoCompletion",
                  let todoText = message["todoText"] as? String,
                  let isCompleted = message["isCompleted"] as? Bool else {
                return
            }

            todoHandler(todoText, isCompleted)
        }
    }
}
