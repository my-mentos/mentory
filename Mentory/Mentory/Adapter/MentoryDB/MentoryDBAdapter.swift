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
    nonisolated let api = MentoryDBAPI()
    
    @concurrent
    func updateName(_ newName: String) async throws {
        try await api.updateName(newName)
    }
    
    @concurrent
    func getName() async throws -> String? {
        let name = try await api.getName()
        
        return name
    }
    
    @concurrent
    func saveRecord(_ data: Values.RecordData) async throws {
        try await api.saveRecord(data)
    }
    
    @concurrent
    func updateActionCompletion(recordId: UUID, completionStatus: [Bool]) async throws {
        try await api.updateActionCompletion(recordId: recordId, completionStatus: completionStatus)
    }

    @concurrent
    func fetchRecordForDate(_ targetDate: Date) async throws -> RecordData? {
        try await api.fetchRecordForDate(targetDate)
    }

    @concurrent
    func hasRecordForDate(_ recordDate: RecordDate) async throws -> Bool {
        try await api.hasRecordForDate(recordDate)
    }

    @concurrent
    func fetchAvailableDatesForWriting() async throws -> [RecordDate] {
        try await api.fetchAvailableDatesForWriting()
    }

    @concurrent
    func fetchAll() async throws -> [RecordData] {
        try await api.fetchAll()
    }
    
    @concurrent
    func fetchToday() async throws -> [RecordData] {
        try await api.fetchToday()
    }
    
    @concurrent
    func fetchByDateRange(from: Date, to: Date) async throws -> [RecordData] {
        try await api.fetchToday(from: from, to: to)
    }
    
    @concurrent
    public func fetchMentorMessage() async throws -> MessageData? {
        let message = try await api.fetchMentorMessage()
        
        return message
    }
    
    @concurrent
    public func saveMentorMessage(_ message: String, _ type: CharacterType) async throws {
        try await api.saveMentorMessage(message, type)
    }
}
