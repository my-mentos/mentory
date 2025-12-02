//
//  MentoryDate.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation


// MARK: Value
nonisolated
public struct MentoryDate: Sendable, Codable, Hashable {
    // MARK: core
    public let rawValue: Date
    public init(_ rawValue: Date) {
        self.rawValue = rawValue
    }
    
    public static var now: Self {
        return MentoryDate(.now)
    }
    
    
    // MARK: operator
    public func relativeDay(from other: MentoryDate) -> RelativeDay {
        let calendar = Calendar.current
        
        let diff = calendar.dateComponents(
            [.day],
            from: other.startOfDay,
            to: self.startOfDay)
            .day
        
        guard let diff else {
            return .unknown
        }
        
        switch diff {
        case 0: return .today
        case -1: return .yesterday
        case -2: return .dayBefoeYesterday
        default: return .unknown
        }
    }
    
    public func formatted() -> String {
        self.rawValue.formatted(
            Date.FormatStyle()
                .locale(Locale(identifier: "ko_KR"))
                .month(.defaultDigits)
                .day(.defaultDigits)
                .weekday(.wide)
        )
    }
    
    
    // MARK: value
    public enum RelativeDay: String, Sendable, Hashable, Codable {
        case today = "오늘"
        case yesterday = "어제"
        case dayBefoeYesterday = "그제"
        case unknown = ""
    }
    
    private var startOfDay: Date {
        Calendar.current.startOfDay(for: rawValue)
    }

}
