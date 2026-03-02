//
//  StatBoard.swift
//  Mentory
//
//  Created by 김민우 on 2/25/26.
//
import Foundation
import Combine
import Values
import MentoryDBAdapter
import OSLog


// MARK: object
@MainActor
public final class StatBoard: ObservableObject {
    // MARK: core
    private let logger = Logger()
    
    init(owner: Mentory) {
        self.owner = owner
    }
    
    // MARK: state
    weak var owner: Mentory?
    
    @Published public var allRecords: [RecordData] = []
    
    
    // MARK: action
    public func loadRecords() async {
        // capture
        let mentoryDB = self.owner!.mentoryDB

        
        // process
        let records: [RecordData]
        do {
            records = try await mentoryDB.getRecords()
        } catch {
            records = []
            logger.error("\(error)")
        }
        
        // mutate
        self.allRecords = records
    }
}
