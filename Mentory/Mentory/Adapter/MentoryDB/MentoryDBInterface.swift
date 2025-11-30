//
//  MentoryDBFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import SwiftData
import OSLog
import Values


// MARK: Interface
protocol MentoryDBInterface: Sendable {
    func updateName(_ newName: String) async throws -> Void
    func getName() async throws -> String?
    
    func saveRecord(_ data: RecordData) async throws -> Void
    func updateActionCompletion(recordId: UUID, completionStatus: [Bool]) async throws -> Void

    func fetchAll() async throws -> [RecordData]
    func fetchToday() async throws -> [RecordData]
    func fetchByDateRange(from: Date, to: Date) async throws -> [RecordData]
    
    func fetchMentorMessage() async throws -> MessageData?
    func saveMentorMessage(_ message: String, _ type: CharacterType) async throws -> Void
}
