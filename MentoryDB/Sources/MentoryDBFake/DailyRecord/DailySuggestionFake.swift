//
//  DailySuggestionFake.swift
//  MentoryDB
//
//  Created by 김민우 on 12/23/25.
//
import Foundation
import Values


// MARK: Fake Object
@MainActor
final class DailySuggestionFake: Sendable {
    // MARK: core
    init(owner: DailyRecordFake, ticketId: UUID, target: SuggestionID, content: String, isDone: Bool) {
        self.owner = owner
        self.ticketId = ticketId
        self.target = target
        self.content = content
        self.isDone = isDone
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: DailyRecordFake?
    nonisolated let ticketId: UUID
    nonisolated let target: SuggestionID
    
    var content: String
    var isDone: Bool
    
    
    // MARK: action
    
    
    // MARK: value
}
