//
//  WatchConnectivityManager.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/26/25.
//

import Foundation
import WatchConnectivity
import Combine

// WatchOS에서 iOS 앱과 통신하기 위한 매니저
@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var todayString: String = "명언을 불러오는 중..."
    @Published var connectionStatus: String = "연결 대기 중"

    private let session: WCSession

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
    func requestDataFromPhone() {
        guard session.isReachable else {
            self.connectionStatus = "iPhone과 연결되지 않음"
            return
        }

        let message = ["request": "initialData"]
        session.sendMessage(message, replyHandler: { [weak self] reply in
            Task { @MainActor in
                self?.handleReceivedData(reply)
            }
        }) { [weak self] error in
            Task { @MainActor in
                self?.connectionStatus = "데이터 요청 실패: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Private Methods

    private func handleReceivedData(_ data: [String: Any]) {
        if let quote = data["todayString"] as? String {
            self.todayString = quote
        }
        self.connectionStatus = "연결됨"
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

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.handleReceivedData(message)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        self.handleReceivedData(message)
        replyHandler(["status": "received"])
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.handleReceivedData(applicationContext)
    }
}
