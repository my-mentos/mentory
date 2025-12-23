//
//  RecordDate.swift
//  Mentory
//
//  Created by 구현모 on 12/01/25.
//
import Foundation


// MARK: Value
@available(*, deprecated, message: "이 함수는 더 이상 사용되지 않을 예정입니다.")
@frozen
nonisolated public enum RecordDate: String, CaseIterable, Identifiable, Sendable {
    case today = "오늘"
    case yesterday = "어제"
    case dayBefore = "그제"

    public var id: String { rawValue }

    /// RecordDate를 실제 Date로 변환
    public func toDate() -> Date {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .today:
            return calendar.startOfDay(for: now)
        case .yesterday:
            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        case .dayBefore:
            return calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: now))!
        }
    }

    /// Date를 RecordDate로 변환 (오늘 기준으로 계산)
    public static func from(_ date: Date) -> RecordDate? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: date)
        let dayDifference = calendar.dateComponents([.day], from: targetDay, to: today).day ?? 0

        switch dayDifference {
        case 0: return .today
        case 1: return .yesterday
        case 2: return .dayBefore
        default: return nil
        }
    }
}
