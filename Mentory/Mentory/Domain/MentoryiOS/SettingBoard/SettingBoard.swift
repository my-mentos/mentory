//
//  SettingBoard.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//

import Foundation
import Combine
import OSLog

// MARK: Object
@MainActor
final class SettingBoard: Sendable, ObservableObject {
    
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    weak var owner: MentoryiOS?
    nonisolated let id = UUID()
    nonisolated private let logger = Logger(
        subsystem: "MentoryiOS.SettingBoard",
        category: "Domain"
    )
    
    /// 알림 사용 여부 (알림 설정 토글)
    @Published var isReminderOn: Bool = true
    
    /// 알림 시간 (알림 시간 표시 + DatePicker)
    @Published var reminderTime: Date = .now
    
    // 화면 클릭
    @Published var isShowingPrivacyPolicy: Bool = false
    @Published var isShowingLicenseInfo: Bool = false
    @Published var isShowingTermsOfService: Bool = false   // 👈 추가
    
    // MARK: value
    
    
    // MARK: action
    
    /// 알림 on/off 토글 액션
    func toggleReminder() {
        isReminderOn.toggle()
        logger.info("Reminder toggled: \(self.isReminderOn)")
    }
    
    /// 알림 시간 변경 액션
    func updateReminderTime(_ newTime: Date) {
        reminderTime = newTime
        logger.info("Reminder time updated: \(String(describing: newTime))")
    }
    
    func showPrivacyPolicy() {
        isShowingPrivacyPolicy = true
    }
    
    func showLicenseInfo() {
        isShowingLicenseInfo = true
    }
    
    func showTermsOfService() {
        isShowingTermsOfService = true
    }
}
