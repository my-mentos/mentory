//
//  MentoryDBMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation


// MARK: Mock
nonisolated
struct MentoryDBMock: MentoryDBFlowInterface {
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
}
