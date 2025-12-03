//
//  DailySuggestion.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import SwiftData
import Values
import OSLog


// MARK: SwiftData Model
@Model
final class DailySuggestionModel {
    @Attribute(.unique) var id: UUID
    
    var target: UUID // SuggestionID의 원시값
    
    var content: String
    var status: SuggestionData.Status
    
    init(id: UUID = UUID(),
         target: UUID,
         content: String,
         status: SuggestionData.Status) {
        self.id = id
        self.target = target
        self.content = content
        self.status = status
    }
}


// MARK: Object
actor DailySuggestion {
    // MARK: core
    init(id: UUID) {
        self.id = id
    }
    nonisolated let id: UUID
    nonisolated let logger = Logger(subsystem: "MentoryDB.DailySuggestion", category: "Domain")
    
    
    // MARK: state
    
    
    // MARK: action
    
    
    // MARK: value
}
