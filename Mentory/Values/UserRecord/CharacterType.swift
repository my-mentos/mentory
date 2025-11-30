//
//  CharacterType.swift
//  Values
//
//  Created by JAY on 11/26/25.
//

import Foundation

// MARK: Value
@frozen
nonisolated public enum CharacterType: String, Codable, Sendable {
    case Nangcheol
    case Gureum
    
   public var title: String {
        switch self {
        case .Nangcheol: return "냉철이가 전하는 오늘의 현실 조언"
        case .Gureum: return "구름이의 따뜻한 한마디"
        }
    }
    
   public var imageName: String {
        switch self {
        case .Nangcheol: return "bunsuk"
        case .Gureum: return "gureum"
        }
    }
    
    public var question: String {
            switch self {
            case .Nangcheol:
                return "동기부여가 될만한 짧은 현실조언을 저번과 다르게 말해줘. 냉정한 태도로 말해줘. 문장에들어가면 어색한 특수문자들은 다 빼줘. 이모지는 어울리게 문장들 사이에 문장이 끝나기 전에 마침표앞에 두개 넣어줘"
            case .Gureum:
                return "마음을 보살펴주는 짧은 위로격려를 저번과 다르게 말해줘. 상냥한 말투로 말해줘. 문장에들어가면 어색한 특수문자들은 다 빼줘. 이모지는 어울리게 문장들 사이에 문장이 끝나기 전에 마침표앞에 두개 넣어줘"
            }
        }
}

