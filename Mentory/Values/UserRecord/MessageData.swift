//
//  MessageData.swift
//  Values
//
//  Created by JAY on 11/26/25.
//

import Foundation

// MARK: value
nonisolated
public struct MessageData: Sendable, Hashable, Codable {
    // MARK: core
    public let id: UUID
    public let createdAt: Date
    public let message: String
    public let characterType: CharacterType

    public init(id: UUID, createdAt: Date, message: String, characterType: CharacterType) {
        self.id = id
        self.createdAt = createdAt
        self.message = message
        self.characterType = characterType
    }
}
