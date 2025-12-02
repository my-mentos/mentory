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
    init(owner: MentoryDBModel,
         createdAt: Date,
         message: String,
         characterType: MentoryCharacter) {
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
    nonisolated let characterType: MentoryCharacter
    
}


