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
    
    func saveRecord(_ data: Values.RecordData) async throws {
        fatalError()
    }
    
    func fetchAll() async throws -> [RecordData] {
        fatalError()
    }
    
    func fetchToday() async throws -> [RecordData] {
        fatalError()
    }
    
    func fetchByDateRange(from: Date, to: Date) async throws -> [RecordData] {
        fatalError()
    }
}
