//
//  MentoryDBMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation


// MARK: Mock
nonisolated
struct MentoryDBMock: MentoryDBInterface {
    @concurrent
    func updateName(_ newName: String) async throws {
        await MainActor.run {
            MentoryDBModel.shared.userName = newName
        }
    }
    
    @concurrent
    func getName() async throws -> String? {
        return await MainActor.run {
            MentoryDBModel.shared.userName
        }
    }
    
    
}
