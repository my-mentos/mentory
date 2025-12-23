//
//  DailyRecordAdapter.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import Foundation
import MentoryDB
import Values


// MARK: Adapter - wrong!
public nonisolated struct DailyRecordAdapter: DailyRecordInterface {
    private let dailyRecord: DailyRecord

    init(_ recordData: DailyRecord) {
        self.dailyRecord = recordData
    }
    
    public func getSuggestions() async throws -> [SuggestionData] {
        await dailyRecord.getSuggestions()
    }
}

