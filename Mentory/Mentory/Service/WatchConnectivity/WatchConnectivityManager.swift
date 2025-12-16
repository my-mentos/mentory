//
//  WatchConnectivityManager.swift
//  Mentory
//
//  Created by 구현모 on 11/26/25.
//
import Foundation
import Combine

/// iOS 앱에서 Watch 앱과 통신하기 위한 매니저
@MainActor @Observable
final class WatchConnectivityManager {
    // MARK: core
    static let shared = WatchConnectivityManager()
    private init() { }

    // MARK: state
    var isPaired: Bool = false
    var isWatchAppInstalled: Bool = false
    var isReachable: Bool = false

    private var engine: WatchConnectivityEngine? = nil


    // MARK: action
    func setUp() async {
        // capture
        guard engine == nil else {
            return
        }

        // process
        let engine = WatchConnectivityEngine.shared
        await engine.setStateUpdateHandler { [weak self] state in
            Task { @MainActor in
                self?.isPaired = state.isPaired
                self?.isWatchAppInstalled = state.isWatchAppInstalled
                self?.isReachable = state.isReachable
            }
        }
        
        engine.activate()

        // mutate
        self.engine = engine
    }

    /// 멘토 메시지를 Watch로 전송
    func updateMentorMessage(_ message: String, character: String) async {
        await engine?.sendMentorMessage(message, character: character)
    }

    /// 행동 추천 투두를 Watch로 전송
    func updateActionTodos(_ todos: [String], completionStatus: [Bool]) async {
        await engine?.sendActionTodos(todos, completionStatus: completionStatus)
    }

    /// 투두 완료 처리 핸들러 설정
    func setTodoCompletionHandler(_ handler: @escaping @Sendable (String, Bool) -> Void) async {
        await engine?.setTodoCompletionHandler(handler)
    }
}
