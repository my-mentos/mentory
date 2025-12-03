//
//  Suggestion.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import Combine
import Values


// MARK: Object
@MainActor
final class Suggestion: Sendable, ObservableObject {
    // MARK: core
    init(owner: TodayBoard,
         target: SuggestionID,
         content: String,
         isDone: Bool) {
        self.owner = owner
        self.target = target
        self.content = content
        self.isDone = isDone
    }
    
    // MARK: state
    nonisolated let id: UUID = UUID()
    
    weak var owner: TodayBoard?
    
    nonisolated let target: SuggestionID
    nonisolated let content: String
    
    @Published private(set) var isDone: Bool
    func setStatus(isDone: Bool) {
        self.isDone = isDone
    }
    
    
    // MARK: action
    func markDone() async {
        // capture
        let todayBoard = self.owner!
        let mentoryiOS = todayBoard.owner!
        
        let mentoryDB = mentoryiOS.mentoryDB
        
        // process
        // SwiftData의 UserSuggestion에 isDone 업데이트
        
        // mutate
        fatalError()
    }
    
    
    // MARK: value
}
