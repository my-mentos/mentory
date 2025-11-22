//
//  RecordData.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import Foundation


// MARK: value
nonisolated
public struct RecordData: Sendable, Hashable, Codable {
    // MARK: core
    public let id: UUID
    public let createdAt: Date
    
    public let content: String
    public let analyzedResult: String
    public let emotion: Emotion
    
    public init(id: UUID, createdAt: Date, content: String, analyzedResult: String, emotion: Emotion) {
        self.id = id
        self.createdAt = createdAt
        self.content = content
        self.analyzedResult = analyzedResult
        self.emotion = emotion
    }
    
    
    // MARK: value
    nonisolated
    public enum Emotion: String, Codable, Sendable {
        case happy, sad, neutral, surprised, scared
    }
}
