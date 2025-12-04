//
//  Suggestion.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import Combine
import Values

import OSLog


// MARK: Object
@MainActor
final class Suggestion: Sendable, ObservableObject, Identifiable {
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
    
    nonisolated private let logger = Logger(subsystem: "Suggestion", category: "Domain")
    
    // MARK: state
    nonisolated let id: UUID = UUID()
    
    weak var owner: TodayBoard?
    
    nonisolated let target: SuggestionID
    nonisolated let content: String
    
    @Published var isDone: Bool
    
    
    // MARK: action
    func markDone() async {
        // capture
        let todayBoard = self.owner!
        let mentoryiOS = todayBoard.owner!
        
        let mentoryDB = mentoryiOS.mentoryDB
        logger.debug("markDone호출")
        if self.isDone == true {
            logger.debug("isDone: \(self.isDone)")
        }
        // process
        // SwiftData의 UserSuggestion에 isDone 업데이트
        
        // mutate
//        fatalError()
    }
    
    
    // MARK: value
}
