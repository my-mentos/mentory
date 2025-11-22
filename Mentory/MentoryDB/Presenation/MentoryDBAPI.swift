//
//  MentoryDBAPI.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import Foundation


// MARK: API
public struct MentoryDBAPI: Sendable {
    // MARK: core
    public init() { }
    
    
    // MARK: API
    @concurrent
    public func updateName(_ newName: String) async throws {
        let mentoryDB = MentoryDB()
        
        await mentoryDB.setName(newName)
        
        return
    }
    
    @concurrent
    public func getName() async throws -> String? {
        let mentoryDB = MentoryDB()
        
        let name = await mentoryDB.getName()
        
        return name
    }
}
