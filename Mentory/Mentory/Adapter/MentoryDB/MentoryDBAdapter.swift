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
    @concurrent
    func updateName(_ newName: String) async throws {
        let api = MentoryDBAPI()
        
        try await api.updateName(newName)
    }
    
    @concurrent
    func getName() async throws -> String? {
        let api = MentoryDBAPI()
        
        let name = try await api.getName()
        
        return name
    }
    
    
    func fetchAll() async throws -> [Values.RecordData] {
        fatalError()
    }
    
    func fetchToday() async throws -> [Values.RecordData] {
        fatalError()
    }
    
    func fetchByDateRange(from: Date, to: Date) async throws -> [RecordData] {
        fatalError()
    }
    
    func delete(_ id: Values.RecordID) async throws {
        fatalError()
    }
}
