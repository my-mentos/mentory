//
//  MentoryCharacter.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation


// MARK: Value
@frozen nonisolated
public enum MentoryCharacter: Sendable, Hashable, CaseIterable, Codable {
    case cool // 구름이
    case warm // 냉철이
    
    public var displayName: String {
        switch self {
        case .cool: return "냉스 처리스키"
        case .warm: return "알렉산더 지방스"
        }
    }
    
    public var description: String {
        switch self {
        case .cool: return "냉철한 분석가 초록이가 감정 분석을 도와드릴게요!"
        case .warm: return "감성적인 조력자 지방이가 따뜻하게 답해드릴게요!"
        }
    }
    
    public var imageName: String {
        switch self {
        case .cool: return "bunsuk"
        case .warm: return "gureum"
        }
    }
    
    public var messageDescription: String {
        switch self {
        case .cool:
            return "상황을 객관적인 시선으로 정리하고, 사용자의 감정과 행동, 패턴과 주요 요인을 냉정하게 해석해줘. 감정적인 위로는 최소화하고, 상황을 논리적으로 해석해주었으면 좋겠어."
        case .warm:
            return "따뜻한 톤으로 이모티콘을 활용해 감정과 상황을 최대한 나이스하게 설명해줘. 사용자가 느낀 감정의 뿌리, 상황적 요인, 스트레스가 높아진 이유 등을 따뜻한 시각으로 풀어주어야 해. 사용자의 감정을 정당화하고 '이런 감정이 드는 건 충분히 그럴 수 있다'는 메시지를 자연스럽게 담아야 해."
        }
    }
}
