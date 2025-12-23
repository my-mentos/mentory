//
//  DailyRecordFakeAdapter.swift
//  MentoryDB
//
//  Created by 김민우 on 12/23/25.
//
import Foundation
import Values
import MentoryDBFake


// MARK: Mock
nonisolated
public struct DailyRecordFakeAdapter: DailyRecordInterface {
    // MARK: core
    nonisolated let object: DailyRecordFake
    init(_ object: DailyRecordFake) {
        self.object = object
    }
    
    
    // MARK: flow
    public func getSuggestions() async throws -> [SuggestionData] {
        return await object.getSuggestions()
    }
}

