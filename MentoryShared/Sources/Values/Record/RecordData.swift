//
//  RecordData.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation


// MARK: Value
nonisolated
public struct RecordData: Sendable, Hashable, Codable, Equatable {
    // MARK: core
    public let id: UUID
    
    public let recordDate: MentoryDate
    public let createdAt: MentoryDate
    
    public let analyzedResult: String
    public let emotion: Emotion
    
    
    public init(id: UUID = .init(),
                recordDate: MentoryDate,
                createdAt: MentoryDate = .now,
                analyzedResult: String,
                emotion: Emotion) {
        self.id = id
        self.recordDate = recordDate
        self.createdAt = createdAt
        self.analyzedResult = analyzedResult
        self.emotion = emotion
    }
}
