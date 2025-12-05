//
//  MentorySwiftDataFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/21/25.
//
import Foundation
import MentoryDB
import Values



// MARK: Domain
nonisolated struct MentoryDBAdapter: MentoryDBInterface {
    private let object = MentoryDatabase.shared
    
    @concurrent func getName() async throws -> String? {
        return await object.getName()
    }
    @concurrent func setName(_ newName: String) async throws {
        await object.setName(newName)
    }
    
    @concurrent func getMentorMessage() async throws -> MessageData? {
        return await object.getMentorMessage()
    }
    @concurrent func setMentorMessage(_ data: MessageData) async throws {
        await object.setMentorMessage(data)
    }
    
    @concurrent func getCharacter() async throws -> MentoryCharacter? {
        return await object.getCharacter()
    }
    @concurrent func setCharacter(_ character: MentoryCharacter) async throws {
        await object.setCharacter(character)
    }
    
    @concurrent func getRecordCount() async throws -> Int {
        await object.getRecordCount()
    }
    @concurrent func isSameDayRecordExist(for date: MentoryDate) async throws -> Bool {
        await object.isSameDayRecordExist(for: date)
    }
    
    @concurrent func getRecentRecord() async throws -> DailyRecordAdapter? {
        guard let recordData = await object.getRecentRecord() else {
            return nil
        }
        return DailyRecordAdapter(recordData: recordData)
    }
    
    @concurrent func submitAnalysis(recordData: RecordData, suggestionData: [SuggestionData]) async throws {
        await object.insertTicket(recordData)
        await object.createDailyRecords()
        await object.insertSuggestions(ticketId: recordData.id, suggestions: suggestionData)
    }
}
