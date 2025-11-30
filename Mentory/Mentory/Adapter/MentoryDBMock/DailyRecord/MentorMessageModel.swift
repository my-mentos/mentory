//
//  MentorMessageModel.swift
//  MentoryDB
//
//  Created by JAY on 11/26/25.
//

import Foundation
import SwiftData
import OSLog
import Values

// MARK: Object
@MainActor
final class MentorMessageModel: Sendable {
    
    // MARK: core
    init(owner: MentoryDBModel? = nil, createdAt: Date, message: String, characterType: CharacterType) {
        self.owner = owner
        self.createdAt = createdAt
        self.message = message
        self.characterType = characterType
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryDBModel?
    nonisolated let createdAt: Date
    
    nonisolated let message: String
    nonisolated let characterType: CharacterType
    
    

//    // MARK: action
//    func toMessageData() -> MessageData {
//        return .init(id: self.id,
//                     createdAt: self.createdAt,
//                     message: self.message,
//                     characterType: self.characterType)
//    }
    
}
