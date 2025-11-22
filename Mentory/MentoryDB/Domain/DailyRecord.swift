//
//  DailyRecord.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import SwiftData
import Foundation


// MARK: Object
actor DailyRecord {
    // MARK: core
    
    
    // MARK: state
    
    
    // MARK: action
    
    
    // MARK: value
    @Model
    final class Model {
        // MARK: core
        @Attribute(.unique) var id: UUID
        
        var createdAt: Date
        var content: String
        var analyzedResult: String
        
        init(id: UUID = UUID(), createdAt: Date, content: String, analyzedResult: String) {
            self.id = id
            self.createdAt = createdAt
            self.content = content
            self.analyzedResult = analyzedResult
        }
    }
}
