//
//  Suggestion.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import Combine
import Values
import MentoryDBAdapter
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

        let targetId = self.target.rawValue
        let isDone = self.isDone

        logger.debug("markDone 호출: isDone=\(isDone)")

        // process - DB에 Suggestion 상태 업데이트
        do {
            try await mentoryDB.updateSuggestionStatus(targetId: targetId, isDone: isDone)
            logger.debug("Suggestion 상태 DB 저장 완료")
        } catch {
            logger.error("Suggestion 상태 업데이트 실패: \(error)")
        }

        // Watch로 전송
        await todayBoard.sendSuggestionsToWatch()

        // 뱃지 갱신
        await todayBoard.fetchEarnedBadges()
    }
    
    
    // MARK: value
}
