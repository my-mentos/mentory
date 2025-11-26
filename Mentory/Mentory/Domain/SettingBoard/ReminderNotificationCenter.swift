//
//  ReminderNotificationCenter.swift
//  Mentory
//
//  Created by SJS on 11/26/25.
//

import Foundation
import UserNotifications

@MainActor
final class ReminderNotificationCenter {

    // MARK: - 알림 권한 요청

    func requestAuthorizationIfNeeded() async {
        
    }


    // MARK: - 7일 뒤 알림 스케줄링

    func scheduleWeeklyReminder(
        baseDate: Date,
        reminderTime: Date
    ) async {
        
    }


    // MARK: -   모든 알림 취소

    func cancelAllWeeklyReminders() async {
        
    }
}
