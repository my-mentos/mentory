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
    public let createdAt: MentoryDate
    public let content: String
    
    public let characterType: MentoryCharacter
    
    public init(createdAt: MentoryDate = .now,
                content: String,
                characterType: MentoryCharacter) {
        self.createdAt = createdAt
        self.content = content
        self.characterType = characterType
    }
}
