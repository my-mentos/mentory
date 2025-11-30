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
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.SettingBoard", category: "Domain")
    
    
    // MARK: state
    weak var owner: MentoryiOS?
    nonisolated let id = UUID()
    
    private static let reminderTimeKey = "mentory.settingBoard.reminderTime"
    private var isApplyingSavedReminderTime = false
    
    @Published var editingName: EditingName? = nil
    
    @Published var isReminderOn: Bool = true
    @Published var reminderTime: Date = .now
    func formattedReminderTime() -> String {
        self.reminderTime
            .formatted(
                .dateTime
                    .hour(.twoDigits(amPM: .omitted)) // 'HH' 및 AM/PM 제거 효과
                    .minute(.twoDigits)               // 'mm'
            )
    }
    
    
    // MARK: action
    func setUpEditingName() {
        // capture
        guard self.editingName == nil else {
            logger.error("이미 SettingBoard에 EditingName이 존재합니다.")
            return
        }
        
        guard let userName = owner!.userName else {
            fatalError("MentoryiOS의 userName이 nil입니다.")
        }
        
        // mutate
        self.editingName = EditingName(owner: self, userName: userName)
    }
    
    func loadSavedReminderTime() {
        guard let savedTime = UserDefaults.standard.object(forKey: Self.reminderTimeKey) as? Date else {
            logger.info("저장된 알림 시간이 없습니다. 기본값: \(String(describing: self.reminderTime))")
            return
        }
        reminderTime = savedTime
    }
    
    func applyChangedReminderTime() {
        guard isApplyingSavedReminderTime == false else { return }
        UserDefaults.standard.set(reminderTime, forKey: Self.reminderTimeKey)
        logger.info("알림 시간이 저장되었습니다: \(String(describing: self.reminderTime))")
    }
    
    
    
    // MARK: value
    
    
}
