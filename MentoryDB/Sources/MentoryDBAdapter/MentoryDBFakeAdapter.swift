//
//  MentoryDBFakeAdapter.swift
//  MentoryDB
//
//  Created by 김민우 on 12/23/25.
//
import Foundation
import Values
import OSLog
import MentoryDBFake


// MARK: Mock
public nonisolated struct MentoryDBFakeAdapter: MentoryDBInterface {
    // MARK: core
    nonisolated let object = MentoryDatabaseFake()
    nonisolated let logger = Logger(subsystem: "MentoryDatabaseMock", category: "Adapter")
    
    public init() {
        
    }
    
    
    // MARK: flow
    public func getName() async throws -> String? {
        return await MainActor.run {
            object.userName
        }
    }
    public func setName(_ newName: String) async throws {
        await MainActor.run {
            object.userName = newName
        }
    }
    public func getRecords() async throws -> [RecordData] {
        return []
    }
    
    public func getMentorMessage() async throws -> Values.MessageData? {
        return await MainActor.run {
            object.message
        }
    }
    public func setMentorMessage(_ data: MessageData) async throws {
        await MainActor.run {
            object.message = data
        }
    }
    
    public func getCharacter() async throws -> MentoryCharacter? {
        return await MainActor.run {
            object.userCharacter
        }
    }
    public func setCharacter(_ character: MentoryCharacter) async throws {
        await MainActor.run {
            object.userCharacter = character
        }
    }
    
    public func getRecordCount() async throws -> Int {
        return await object.records.count
    }
    public func isSameDayRecordExist(for date: MentoryDate) async throws -> Bool {
        return await object.isSameDayRecordExist(date)
    }
    public func getRecentRecord() async throws -> DailyRecordFakeAdapter? {
        guard let dailyRecord = await object.getRecentRecord() else {
            logger.error("최근 DailyRecord가 존재하지 않습니다.")
            return nil
        }
        
        return .init(dailyRecord)
    }
    
    public func getSuggestions(by id: UUID) async throws -> [SuggestionData] {

        // 1) DailyRecordFake 찾기
        guard let dailyRecord = await object.getDailyRecord(ticketId: id) else {
            logger.error("Mock: DailyRecord(id: \(id)) 없음 → 빈 배열 반환")
            return []
        }

        // 2) DailyRecordFake 내에서 SuggestionData 가져오기
        return await dailyRecord.getSuggestions()
    }
    

    public func getCompletedSuggestionsCount() async throws -> Int {
        return await object.getCompletedSuggestionsCount()
    }

    public func updateSuggestionStatus(targetId: UUID, isDone: Bool) async throws {
        await object.updateSuggestionStatus(targetId: targetId, isDone: isDone)
    }


    public func submitAnalysis(recordData: RecordData, suggestionData: [SuggestionData]) async throws {
        
        // create DailyRecord
        await object.insertTicket(recordData)
        await object.createDailyRecords()
        
        guard let dailyRecord = await object.getDailyRecord(ticketId: recordData.id) else {
            logger.error("\(recordData.id.uuidString.prefix(6))에 해당하는 DailyRecord가 없습니다.")
            return
        }
        
        // create DailySuggestion
        await dailyRecord.insertTicket(suggestionData)
        await dailyRecord.createDailySuggestions()
        
    }
}
