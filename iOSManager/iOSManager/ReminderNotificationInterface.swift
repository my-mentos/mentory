//
//  ReminderNotificationInterface.swift
//  iOSManager
//
//  Created by 김민우 on 12/23/25.
//
import Foundation

public protocol ReminderNotificationInterface: Sendable {
    func requestAuthorizationIfNeeded() async
    func scheduleWeeklyReminder(baseDate: Date, reminderTime: Date) async
    func cancelAllWeeklyReminders() async
}
