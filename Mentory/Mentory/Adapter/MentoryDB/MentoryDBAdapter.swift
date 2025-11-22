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
}
