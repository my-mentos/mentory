//
//  MentoryDB.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation


// MARK: Interface
protocol MentoryDBFlow: Sendable {
    func updateName(_ newName: String) async throws -> Void
    func getName() async throws -> String
}



// MARK: Flow
nonisolated
struct MentoryDB: MentoryDBFlow {
    // MARK: core
    nonisolated let id: UUID
    nonisolated init(_ id: UUID) {
        self.id = id
    }
    
    
    // MARK: flow
    @concurrent
    func updateName(_ newName: String) async throws -> Void {
        fatalError()
    }
    
    @concurrent
    func getName() async throws -> String {
        fatalError()
    }
}
