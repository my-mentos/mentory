//
//  MentoryCharacter.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation


// MARK: Value
@frozen nonisolated
public enum MentoryCharacter: String, Sendable, Hashable, CaseIterable, Codable {
    // MARK: core
    case cool // 냉철이
    case warm // 구름이
    
    public static var random: MentoryCharacter {
        Bool.random() ? .cool : .warm
    }
    
    
    // MARK: operator
    public var title: String {
        switch self {
        case .cool: return "냉철이가 전하는 오늘의 현실 조언"
        case .warm: return "구름이의 따뜻한 한마디"
        }
    }
    
    public var imageName: String {
        switch self {
        case .cool: return "cool"
        case .warm: return "warm"
        }
    }
    
    public var displayName: String {
        switch self {
        case .cool: return "냉스 처리스키"
        case .warm: return "알렉산더 구름스"
        }
    }
    
    public var description: String {
        switch self {
        case .cool: return "논리적인 분석가 냉철이가 해석을 도와드릴게요!"
        case .warm: return "감성적인 조력자 구름이가 따뜻하게 답해드릴게요!"
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
    
    // 오늘의 한마디를 가져오기 위한 질문
    public var question: String {
        switch self {
        case .cool:
            return "동기부여가 될만한 짧은 현실조언을 저번과 다르게 말해줘. 냉정한 태도로 말해줘. 문장에들어가면 어색한 특수문자들은 다 빼줘. 이모지는 어울리게 문장들 사이에 문장이 끝나기 전에 마침표앞에 두개 넣어줘"
        case .warm:
            return "마음을 보살펴주는 짧은 위로격려를 저번과 다르게 말해줘. 상냥한 말투로 말해줘. 문장에들어가면 어색한 특수문자들은 다 빼줘. 이모지는 어울리게 문장들 사이에 문장이 끝나기 전에 마침표앞에 두개 넣어줘"
        }
    }
}
