//
//  MentoryDBMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation
import Values


// MARK: Mock
nonisolated
struct MentoryDBMock: MentoryDBInterface {
    
    // MARK: core
    nonisolated let model = MentoryDBModel()
    
    
    // MARK: flow
    @concurrent
    func updateName(_ newName: String) async throws {
        await MainActor.run {
            model.userName = newName
        }
    }
    
    @concurrent
    func getName() async throws -> String? {
        return await MainActor.run {
            model.userName
        }
    }
    
    @concurrent
    func saveRecord(_ data: RecordData) async throws {
        await MainActor.run {
            model.createRecordQueue.append(data)
            
            model.createDailyRecords()
        }
    }

    @concurrent
    func updateActionCompletion(recordId: UUID, completionStatus: [Bool]) async throws {
        await MainActor.run {
            model.updateActionCompletion(recordId: recordId, completionStatus: completionStatus)
        }
    }

    @concurrent
    func fetchAll() async throws -> [RecordData] {
        await MainActor.run {
            model.getAllRecords()
        }
    }
    
    @concurrent
    func fetchToday() async throws -> [RecordData] {
        await MainActor.run {
            model.getTodayRecords()
        }
    }
    
    @concurrent
    func fetchByDateRange(from: Date, to: Date) async throws -> [RecordData] {
        await MainActor.run {
            model.getRecords(from: from, to: to)
        }
    }
    
    @concurrent
    func fetchMentorMessage() async throws -> Values.MessageData? {
        return await MainActor.run {
            model.getMentorMessage()
        }
        
    }
    
    @concurrent
    func saveMentorMessage(_ message: String, _ type: CharacterType) async throws {
        await MainActor.run {
            model.setMentorMessage(message, type)
        }
    }
}
