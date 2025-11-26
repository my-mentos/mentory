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
        logger.debug("SettingBoard.setUpEditingName 호출")
        
        // capture
        guard self.editingName == nil else {
            logger.error("이미 SettingBoard에 EditingName이 존재합니다.")
            return
        }
        
        // mutate
        self.editingName = EditingName(owner: self, userName: owner?.userName ?? "")
        
    }
    
    func turnReminderOn() {
        logger.debug("SettingBoard.turnReminderOn 호출")
    }

    func turnReminderOff() {
        logger.debug("SettingBoard.turnReminderOff 호출")
    }


    func changeReminderTime(to newDate: Date) {
        logger.debug("SettingBoard.changeReminderTime 호출")
        
        // capture
        let newDate = newDate
        
        // mutate
        self.reminderTime = newDate
        applyChangedReminderTime()
        
        // 구현필요: 이미 예약된 알림은 그대로 두고, 이후 새로 예약되는 알림부터 변경된 시간을 사용한다.

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
 
    // 데이터 삭제 버튼 탭 처리 (확인 Alert 노출)
//    func requestDataDeletion() {
//        logger.info("데이터 삭제 확인 Alert를 노출합니다.")
//    }
//    
//    func cancelDataDeletion() {
//        logger.info("데이터 삭제가 취소되었습니다.")
//    }
    
    func confirmDataDeletion() {
        logger.info("데이터 삭제를 진행합니다. 실제 삭제 로직은 추후 구현 예정")
        // TODO: 추후 담당자가 삭제 로직 구현
    }
    
    
    
    
    // MARK: value
    
    
}
