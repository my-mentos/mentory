//
//  BadgeType.swift
//  Mentory
//
//  Created by 구현모 on 12/8/25.
//
import Foundation


// MARK: Badge Type
public enum BadgeType: String, Sendable, Hashable, Codable, CaseIterable {
    case first = "첫 제안 달성"
    case five = "5개 제안 달성"
    case ten = "10개 제안 달성"
    case twenty = "20개 제안 달성"
    case thirty = "30개 제안 달성"
    case forty = "40개 제안 달성"
    case fifty = "50개 제안 달성"

    /// 뱃지를 획득하기 위해 필요한 완료된 제안 개수
    public var requiredCount: Int {
        switch self {
        case .first: return 1
        case .five: return 5
        case .ten: return 10
        case .twenty: return 20
        case .thirty: return 30
        case .forty: return 40
        case .fifty: return 50
        }
    }

    /// 뱃지 아이콘 (SF Symbol)
    public var iconName: String {
        switch self {
        case .first: return "sparkles"
        case .five: return "star.circle.fill"
        case .ten: return "star.fill"
        case .twenty: return "flame.fill"
        case .thirty: return "medal.fill"
        case .forty: return "trophy.fill"
        case .fifty: return "crown.fill"
        }
    }

    /// 뱃지 설명
    public var description: String {
        switch self {
        case .first: return "첫 번째 제안을 완료했어요!"
        case .five: return "5개의 제안을 완료했어요!"
        case .ten: return "10개의 제안을 완료했어요!"
        case .twenty: return "20개의 제안을 완료했어요!"
        case .thirty: return "30개의 제안을 완료했어요!"
        case .forty: return "40개의 제안을 완료했어요!"
        case .fifty: return "50개의 제안을 완료했어요!"
        }
    }

    /// 완료된 제안 개수에 따라 획득한 뱃지 리스트 반환
    public static func earnedBadges(completedCount: Int) -> [BadgeType] {
        return BadgeType.allCases.filter { badge in
            completedCount >= badge.requiredCount
        }
    }

    /// 다음 획득 가능한 뱃지 반환
    public static func nextBadge(completedCount: Int) -> BadgeType? {
        return BadgeType.allCases.first { badge in
            completedCount < badge.requiredCount
        }
    }
}
