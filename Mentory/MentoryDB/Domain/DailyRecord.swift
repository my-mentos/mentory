//
//  DailyRecord.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import SwiftData
import Values
import Foundation
import OSLog


// MARK: Object
actor DailyRecord: Sendable {
    // MARK: core
    
    
    // MARK: state
    
    
    // MARK: action
    func delete() async {
        
    }
    
    
    // MARK: value
    @Model
    final class Model {
        // MARK: core
        @Attribute(.unique) var id: UUID
        var createdAt: Date
        
        var content: String
        var analyzedResult: String
        var emotion: RecordData.Emotion
        
        init(id: UUID = UUID(), createdAt: Date, content: String, analyzedResult: String) {
            self.id = id
            self.createdAt = createdAt
            self.content = content
            self.analyzedResult = analyzedResult
        }
        
        
        // MARK: operator
        func toData() -> RecordData {
            return .init(id: self.id,
                         createdAt: self.createdAt,
                         content: self.content,
                         analyzedResult: self.analyzedResult,
                         emotion: self.emotion)
        }
    }
}
