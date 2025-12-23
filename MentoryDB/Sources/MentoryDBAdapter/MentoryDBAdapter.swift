//
//  MentoryDBAdapter.swift
//  MentoryDB
//
//  Created by 김민우 on 11/21/25.
//
import Foundation
import MentoryDB
import Values



// MARK: Adapter
public nonisolated struct MentoryDBAdapter: MentoryDBInterface {
    // MARK: core
    private let mentoryDB = MentoryDBReal.shared
    
    public init() { }
    
    
    // MARK: task
    public func getName() async throws -> String? {
        return await mentoryDB.getName()
    }
    public func setName(_ newName: String) async throws {
        await mentoryDB.setName(newName)
    }
    
    public func getMentorMessage() async throws -> MessageData? {
        return await mentoryDB.getMentorMessage()
    }
    public func setMentorMessage(_ data: MessageData) async throws {
        await mentoryDB.setMentorMessage(data)
    }
    
    public func getCharacter() async throws -> MentoryCharacter? {
        return await mentoryDB.getCharacter()
    }
    public func setCharacter(_ character: MentoryCharacter) async throws {
        await mentoryDB.setCharacter(character)
    }
    
    public func getRecordCount() async throws -> Int {
        await mentoryDB.getRecordCount()
    }
    public func isSameDayRecordExist(for date: MentoryDate) async throws -> Bool {
        await mentoryDB.isSameDayRecordExist(for: date)
    }
    

    public func getRecentRecord() async throws -> DailyRecordAdapter? {
        guard let dailyRecord = await mentoryDB.getRecentRecord() else {
            return nil
        }
        
        return DailyRecordAdapter(dailyRecord)
    }
    public func getRecords() async throws -> [RecordData] {
        return await mentoryDB.getRecords()
    }

    public func getCompletedSuggestionsCount() async throws -> Int {
        await mentoryDB.getCompletedSuggestionsCount()
    }

    public func updateSuggestionStatus(targetId: UUID, isDone: Bool) async throws {
        await mentoryDB.updateSuggestionStatus(targetId: targetId, isDone: isDone)
    }

    public func submitAnalysis(recordData: RecordData, suggestionData: [SuggestionData]) async throws {
        await mentoryDB.insertTicket(recordData)
        await mentoryDB.createDailyRecords()
        
        
        await mentoryDB.insertSuggestions(ticketId: recordData.id, suggestions: suggestionData)
    }
}
