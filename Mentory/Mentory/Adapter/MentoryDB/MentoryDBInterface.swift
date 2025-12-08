//
//  MentoryDBFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import SwiftData
import OSLog
import Values



// MARK: Interface
protocol MentoryDBInterface: Sendable {
    associatedtype DailyRecord: DailyRecordInterface
    
    func setName(_ newName: String) async throws
    func getName() async throws -> String?

    func getMentorMessage() async throws -> MessageData?
    func setMentorMessage(_ data: MessageData) async throws
    
    func getCharacter() async throws -> MentoryCharacter?
    func setCharacter(_: MentoryCharacter) async throws
    
    func getRecordCount() async throws -> Int
    func isSameDayRecordExist(for: MentoryDate) async throws -> Bool
    func getRecentRecord() async throws -> DailyRecord?

    func getCompletedSuggestionsCount() async throws -> Int
    func updateSuggestionStatus(targetId: UUID, isDone: Bool) async throws

    func submitAnalysis(recordData: RecordData, suggestionData: [SuggestionData]) async throws
}
