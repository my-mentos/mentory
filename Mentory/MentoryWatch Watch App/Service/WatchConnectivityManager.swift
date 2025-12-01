//
//  WatchConnectivityManager.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/26/25.
//

import Foundation
@preconcurrency import WatchConnectivity
import Combine

// WatchOS에서 iOS 앱과 통신하기 위한 매니저
@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var todayString: String = "명언을 불러오는 중..."
    @Published var mentorMessage: String = "멘토 메시지를 불러오는 중..."
    @Published var mentorCharacter: String = ""
    @Published var connectionStatus: String = "연결 대기 중"

    nonisolated private let session: WCSession
    nonisolated(unsafe) private var cachedTodayString: String = ""
    nonisolated(unsafe) private var cachedMentorMessage: String = ""
    nonisolated(unsafe) private var cachedMentorCharacter: String = ""

    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            self.session.activate()
        }
    }

    // MARK: - Public Methods

    // iOS 앱에 데이터 요청
    nonisolated func requestDataFromPhone() {
        guard session.isReachable else {
            Task { @MainActor in
                self.connectionStatus = "iPhone과 연결되지 않음"
            }
            return
        }

        let message = ["request": "initialData"]
        session.sendMessage(message, replyHandler: { [weak self] reply in
            guard let self = self else { return }

            let quote = reply["todayString"] as? String ?? ""
            let mentorMsg = reply["mentorMessage"] as? String ?? ""
            let character = reply["mentorCharacter"] as? String ?? ""

            self.cachedTodayString = quote
            self.cachedMentorMessage = mentorMsg
            self.cachedMentorCharacter = character

            Task { @MainActor in
                self.todayString = quote
                self.mentorMessage = mentorMsg
                self.mentorCharacter = character
                self.connectionStatus = "연결됨"
            }
        })
    }

    // MARK: - Private Methods

    nonisolated private func updateData(quote: String?, mentorMsg: String?, character: String?) {
        if let quote = quote {
            self.cachedTodayString = quote
        }
        if let mentorMsg = mentorMsg {
            self.cachedMentorMessage = mentorMsg
        }
        if let character = character {
            self.cachedMentorCharacter = character
        }

        Task { @MainActor in
            if let quote = quote {
                self.todayString = quote
            }
            if let mentorMsg = mentorMsg {
                self.mentorMessage = mentorMsg
            }
            if let character = character {
                self.mentorCharacter = character
            }
            self.connectionStatus = "연결됨"
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            switch activationState {
            case .activated:
                self.connectionStatus = "활성화됨"
                self.requestDataFromPhone()
            case .inactive:
                self.connectionStatus = "비활성화됨"
            case .notActivated:
                self.connectionStatus = "활성화 안됨"
            @unknown default:
                self.connectionStatus = "알 수 없는 상태"
            }

            if let error = error {
                self.connectionStatus = "오류: \(error.localizedDescription)"
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let quote = message["todayString"] as? String
        let mentorMsg = message["mentorMessage"] as? String
        let character = message["mentorCharacter"] as? String

        updateData(quote: quote, mentorMsg: mentorMsg, character: character)
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let quote = message["todayString"] as? String
        let mentorMsg = message["mentorMessage"] as? String
        let character = message["mentorCharacter"] as? String

        updateData(quote: quote, mentorMsg: mentorMsg, character: character)
        replyHandler(["status": "received"])
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let quote = applicationContext["todayString"] as? String
        let mentorMsg = applicationContext["mentorMessage"] as? String
        let character = applicationContext["mentorCharacter"] as? String

        updateData(quote: quote, mentorMsg: mentorMsg, character: character)
    }
}
