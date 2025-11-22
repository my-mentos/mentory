//
//  MentoryDBAPI.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import Foundation
import Values


// MARK: API
public struct MentoryDBAPI: Sendable {
    // MARK: core
    nonisolated let mentoryDB = MentoryDB()
    public init() { }
    
    
    // MARK: API
    @concurrent
    public func updateName(_ newName: String) async throws {
        await mentoryDB.setName(newName)
    }
    
    @concurrent
    public func getName() async throws -> String? {
        return await mentoryDB.getName()
    }
    
    @concurrent
    public func fetchAll() async throws -> [RecordData] {
        return await mentoryDB.getAllRecords()
    }
    
    @concurrent
    public func fetchToday() async throws -> [RecordData] {
        return await mentoryDB.getTodayRecordDatas()
    }
    
    @concurrent
    public func fetchToday(from: Date, to: Date) async throws -> [RecordData] {
        return await mentoryDB.getRecords(from: from, to: to)
    }
    
    @concurrent
    public func saveRecord(_ data: RecordData) async throws {
        await mentoryDB.insertDataInQueue(data)
        
        await mentoryDB.createDailyRecords()
    }
}
