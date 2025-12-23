//
//  MentoryDBAdapter.swift
//  MentoryDB
//
//  Created by 김민우 on 11/21/25.
//
import Foundation
import MentoryDB
import Values



// MARK: Domain
nonisolated struct MentoryDBAdapter: MentoryDBInterface {
    private let mentoryDB = MentoryDBReal.shared
    
    @concurrent func getName() async throws -> String? {
        return await mentoryDB.getName()
    }
    @concurrent func setName(_ newName: String) async throws {
        await mentoryDB.setName(newName)
    }
    
    @concurrent func getMentorMessage() async throws -> MessageData? {
        return await mentoryDB.getMentorMessage()
    }
    @concurrent func setMentorMessage(_ data: MessageData) async throws {
        await mentoryDB.setMentorMessage(data)
    }
    
    @concurrent func getCharacter() async throws -> MentoryCharacter? {
        return await mentoryDB.getCharacter()
    }
    @concurrent func setCharacter(_ character: MentoryCharacter) async throws {
        await mentoryDB.setCharacter(character)
    }
    
    @concurrent func getRecordCount() async throws -> Int {
        await mentoryDB.getRecordCount()
    }
    @concurrent func isSameDayRecordExist(for date: MentoryDate) async throws -> Bool {
        await mentoryDB.isSameDayRecordExist(for: date)
    }
    

    @concurrent func getRecentRecord() async throws -> DailyRecordAdapter? {
        guard let dailyRecord = await mentoryDB.getRecentRecord() else {
            return nil
        }
        
        return DailyRecordAdapter(dailyRecord)
    }
    @concurrent func getRecords() async throws -> [RecordData] {
        return await mentoryDB.getRecords()
    }

    @concurrent func getCompletedSuggestionsCount() async throws -> Int {
        await mentoryDB.getCompletedSuggestionsCount()
    }

    @concurrent func updateSuggestionStatus(targetId: UUID, isDone: Bool) async throws {
        await mentoryDB.updateSuggestionStatus(targetId: targetId, isDone: isDone)
    }

    @concurrent func submitAnalysis(recordData: RecordData, suggestionData: [SuggestionData]) async throws {
        await mentoryDB.insertTicket(recordData)
        await mentoryDB.createDailyRecords()
        
        
        await mentoryDB.insertSuggestions(ticketId: recordData.id, suggestions: suggestionData)
    }
}
