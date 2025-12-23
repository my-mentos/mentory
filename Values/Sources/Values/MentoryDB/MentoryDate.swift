//
//  MentoryDate.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation



// MARK: Value
/// Mentory에서 사용되는 날짜 래퍼 타입입니다.
///
/// - `Date`를 그대로 사용할 때는 시, 분, 초까지 모두 포함되어 비교/연산이 복잡해질 수 있습니다.
/// - `MentoryDate`는 "하루"라는 개념에 집중해서, 날짜 비교 / 포맷 / 상대일 계산 등을 돕는 유틸리티 메서드를 제공합니다.
///
/// ```swift
/// let today = MentoryDate.now
/// let yesterday = today.dayBefore()
/// let description = today.formatted()   // 예: "12월 3일 수요일"
/// ```
nonisolated
public struct MentoryDate: Sendable, Codable, Hashable, Comparable {
    // MARK: core
    public let rawValue: Date
    public init(_ rawValue: Date) {
        self.rawValue = rawValue
    }
    
    public static var now: Self {
        return MentoryDate(.now)
    }
    
    
    // MARK: operator
    /// 다른 `MentoryDate`와 비교했을 때, 현재 인스턴스가 "오늘/어제/그제/알 수 없음" 중 어디에 해당하는지 계산합니다.
    ///
    /// 날짜 비교 시 시각(시, 분, 초)은 무시하고, 하루의 시작 시각(`startOfDay`)을 기준으로 일(day) 단위 차이를 계산합니다.
    ///
    /// - Parameter other: 비교 기준이 되는 날짜 (예: 오늘을 기준으로 어제/그제 판단).
    /// - Returns: `RelativeDay.today`, `.yesterday`, `.dayBefoeYesterday`, `.unknown` 중 하나.
    ///
    /// ```swift
    /// let today = MentoryDate.now
    /// let yesterday = today.dayBefore()
    /// let twoDaysAgo = today.twoDaysBefore()
    ///
    /// today.relativeDay(from: today)        // .today
    /// yesterday.relativeDay(from: today)    // .yesterday
    /// twoDaysAgo.relativeDay(from: today)   // .dayBefoeYesterday
    /// ```
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
    
    /// 시, 분, 초를 모두 00:00:00으로 맞춘 "하루의 시작 시각"입니다.
    ///
    /// 날짜 간의 차이를 구할 때, 순수하게 "날짜"만 비교하기 위해 사용됩니다.
    ///
    /// ```swift
    /// // 예시: 같은 날짜라면 서로 같은 startOfDay를 가집니다.
    /// let date1 = MentoryDate(Date())
    /// let date2 = MentoryDate(Date().addingTimeInterval(60 * 60 * 23))
    /// // 같은 날에 속하는 시각이라면 startOfDay는 동일합니다.
    /// ```
    private var startOfDay: Date {
        Calendar.current.startOfDay(for: rawValue)
    }

    /// 두 `MentoryDate`가 같은 "날짜(년/월/일)"인지 여부를 반환합니다.
    ///
    /// 시, 분, 초는 무시하고 같은 달력 날짜에 속하는지만 비교합니다.
    ///
    /// - Parameter other: 비교 대상이 되는 `MentoryDate`.
    /// - Returns: 두 날짜가 같은 날이면 `true`, 아니면 `false`.
    ///
    /// ```swift
    /// let morning = MentoryDate(Date())                     // 2025-12-03 09:00
    /// let night = MentoryDate(Date().addingTimeInterval(60 * 60 * 10)) // 2025-12-03 19:00 (예시)
    ///
    /// morning.isSameDate(as: night) // true
    /// ```
    public func isSameDate(as other: MentoryDate) -> Bool {
        return Calendar.current
            .isDate(self.rawValue,
                    inSameDayAs: other.rawValue)
    }
    
    /// 한국어 로케일(`ko_KR`) 기준으로 날짜를 "월/일 요일" 형식의 문자열로 포맷합니다.
    ///
    /// 예) `"12월 3일 수요일"`
    ///
    /// - Returns: 사람이 읽기 쉬운 한국어 형식의 날짜 문자열.
    ///
    /// ```swift
    /// let today = MentoryDate.now
    /// let text = today.formatted()
    /// print(text)    // "12월 3일 수요일"
    /// ```
    public func formatted() -> String {
        self.rawValue.formatted(
            Date.FormatStyle()
                .locale(Locale(identifier: "ko_KR"))
                .month(.defaultDigits)
                .day(.defaultDigits)
                .weekday(.wide)
        )
    }
    
    
    /// 현재 날짜에서 정확히 하루 전(1일 전)의 `MentoryDate`를 반환합니다.
    ///
    /// - Returns: self보다 1일 이전 날짜를 나타내는 `MentoryDate`.
    ///
    /// ```swift
    /// let today = MentoryDate.now
    /// let yesterday = today.dayBefore()
    ///
    /// print(today.formatted())     // 예: "12월 3일 수요일"
    /// print(yesterday.formatted()) // 예: "12월 2일 화요일"
    /// ```
    public func dayBefore() -> MentoryDate {
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: -1, to: self.rawValue) ?? self.rawValue
        return MentoryDate(newDate)
    }

    /// 현재 날짜에서 정확히 이틀 전(2일 전)의 `MentoryDate`를 반환합니다.
    ///
    /// - Returns: self보다 2일 이전 날짜를 나타내는 `MentoryDate`.
    ///
    /// ```swift
    /// let today = MentoryDate.now
    /// let twoDaysAgo = today.twoDaysBefore()
    ///
    /// print(twoDaysAgo.formatted()) // 예: "12월 1일 월요일"
    /// ```
    public func twoDaysBefore() -> MentoryDate {
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: -2, to: self.rawValue) ?? self.rawValue
        return MentoryDate(newDate)
    }
    
    /// 현재 날짜에서 정확히 하루 뒤(1일 후)의 `MentoryDate`를 반환합니다.
    ///
    /// - Returns: self보다 1일 이후 날짜를 나타내는 `MentoryDate`.
    ///
    /// ```swift
    /// let today = MentoryDate.now
    /// let tomorrow = today.dayAfter()
    ///
    /// print(tomorrow.formatted()) // 예: "12월 4일 목요일"
    /// ```
    public func dayAfter() -> MentoryDate {
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: 1, to: self.rawValue) ?? self.rawValue
        return MentoryDate(newDate)
    }
    
    /// 현재 MentoryDate와 같은 날짜지만 시/분/초가 랜덤한 Date를 반환합니다.
    ///
    /// 같은 날짜이지만, 하루(0시~23:59:59) 내의 무작위 시각이 필요할 때 사용됩니다.
    /// 예: 기록 데이터 생성 테스트 / 더미 데이터 생성 / 무작위 타임스탬프 연출.
    ///
    /// ```swift
    /// let today = MentoryDate.now
    /// let random = today.randomTimeInSameDay()
    /// print(random)   // 예: 2025-12-03 14:27:51
    /// ```
    public func randomTimeInSameDay() -> MentoryDate {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: rawValue)
        
        // 하루의 총 초: 24 * 60 * 60 = 86400
        let secondsInDay = 24 * 60 * 60
        let randomOffset = Int.random(in: 0 ..< secondsInDay)
        
        let newDate = calendar.date(byAdding: .second, value: randomOffset, to: start) ?? rawValue
        return MentoryDate(newDate)
    }
    
    /// 두 `MentoryDate` 값을 비교할 수 있도록 하는 연산자입니다.
    ///
    /// 내부적으로 보관 중인 `rawValue`(`Date`)를 기준으로 오름차순 정렬이 가능해집니다.
    /// 예를 들어, `sorted()` 호출 시 가장 과거의 날짜부터 정렬됩니다.
    public static func < (lhs: MentoryDate, rhs: MentoryDate) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    
    // MARK: value
    /// 두 날짜 간의 상대적인 관계를 간단한 한국어 표현으로 나타내는 열거형입니다.
    ///
    /// `relativeDay(from:)` 메서드의 반환 타입으로 사용됩니다.
    public enum RelativeDay: String, Sendable, Hashable, Codable {
        /// 기준 날짜와 비교했을 때 같은 날(오늘)에 해당함을 나타냅니다.
        case today = "오늘"
        /// 기준 날짜보다 하루 전(어제)에 해당함을 나타냅니다.
        case yesterday = "어제"
        /// 기준 날짜보다 이틀 전(그제)에 해당함을 나타냅니다.
        case dayBefoeYesterday = "그제"
        /// 오늘/어제/그제 중 어디에도 해당하지 않거나, 계산이 불가능한 경우를 나타냅니다.
        case unknown = ""
    }
    
    
}
