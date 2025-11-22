//
//  MentoryDBFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import SwiftData
import OSLog


// MARK: Domain Interface
protocol MentoryDBFlowInterface: Sendable {
    func updateName(_ newName: String) async throws -> Void
    func getName() async throws -> String?
}



//// MARK: Domain
//struct MentoryDBFlow: MentoryDBFlowInterface {
//    // MARK: core
//    nonisolated let id: String = "mentoryDB"
//    nonisolated let nameKey = "mentoryDB.name"
//    
//    nonisolated let logger = Logger(subsystem: "MentoryiOS.MentoryDB", category: "Domain")
//    
//    
//    // MARK: flow
//    @concurrent
//    func updateName(_ newName: String) async throws -> Void {
//         UserDefaults.standard.set(newName, forKey: nameKey)
//    }
//    
//    @concurrent
//    func getName() async throws -> String? {
//        guard let name = UserDefaults.standard.string(forKey: nameKey) else {
//           return nil
//       }
//       return name
//    }
//}
