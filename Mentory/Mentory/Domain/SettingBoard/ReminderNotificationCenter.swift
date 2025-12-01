//
//  ReminderNotificationCenter.swift
//  Mentory
//
//  Created by SJS on 11/26/25.
//

import Foundation
import UserNotifications
import OSLog

@MainActor
final class ReminderNotificationCenter {
    
    nonisolated private let logger = Logger(
        subsystem: "MentoryiOS.ReminderNotificationCenter",
        category: "Notification"
    )
    
    // MARK: - 알림 권한 요청
    
    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                
                if granted {
                    logger.info("알림 권한이 허용되었습니다.")
                } else {
                    logger.error("알림 권한이 거부되었습니다.")
                }
            } catch {
                logger.error("알림 권한 요청 중 오류 발생: \(String(describing: error), privacy: .public)")
            }
            
        case .denied:
            logger.error("알림 권한이 시스템 설정에서 거부된 상태입니다.")
            // 여기서는 단순히 로그만 남기고 설정 이동 안내는 나중에 UI에서 처리하기.
            
        case .authorized, .provisional, .ephemeral:
            logger.debug("알림 권한이 이미 허용된 상태입니다.")
            
        @unknown default:
            logger.error("알 수 없는 알림 권한 상태입니다.")
        }
    }
    
    // MARK: - 7일 뒤 알림 스케줄링
    
    func scheduleWeeklyReminder(
        baseDate: Date,
        reminderTime: Date
    ) async {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        guard let plus7Date = calendar.date(byAdding: .day, value: 7, to: baseDate) else {
            logger.error("baseDate에 7일을 더하는 데 실패했습니다.")
            return
        }
        
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        var components = calendar.dateComponents([.year, .month, .day], from: plus7Date)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        
        guard let fireDate = calendar.date(from: components) else {
            logger.error("알림 발송 시각(fireDate) 계산에 실패했습니다.")
            return
        }
        
        let triggerComponents = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        
        let content = UNMutableNotificationContent()
        content.title = "일기를 작성한 지 일주일이 지났어요"
        content.body = "그때의 나와 지금의 나를 비교해보는 건 어떨까요?"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerComponents,
            repeats: false
        )
        
        // UNNotificationRequest에서 identifier를 일단 UUID로 설정.
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            logger.info("리마인더 알림 등록 완료: \(fireDate, privacy: .public)")
        } catch {
            logger.error("리마인더 알림 등록 실패: \(String(describing: error), privacy: .public)")
        }
    }
    
    
    // MARK: -   모든 알림 취소
    
    func cancelAllWeeklyReminders() async {
        let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()
        logger.info("모든 리마인더 알림을 취소했습니다.")
    }
}
