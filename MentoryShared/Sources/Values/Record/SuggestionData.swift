//
//  SuggestionData.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation


// MARK: Value
nonisolated
public struct SuggestionData: Sendable, Hashable, Codable {
    // MARK: core
    public let id: UUID
    
    public let target: SuggestionID
    
    public let content: String
    public let isDone: Bool
    
    public init(id: UUID = .init(),
                target: SuggestionID = .random,
                content: String,
                isDone: Bool = false) {
        self.id = id
        self.target = target
        self.content = content
        self.isDone = isDone
    }
}
