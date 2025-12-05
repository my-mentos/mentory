//
//  DailyRecordAdapter.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import Foundation
import Values


// MARK: Adapter
nonisolated struct DailyRecordAdapter: DailyRecordInterface {
    private let recordData: RecordData

    public init(recordData: RecordData) {
        self.recordData = recordData
    }

    @concurrent func getSuggestions() async throws -> [SuggestionData] {
        fatalError("구현 예정입니다.")
    }
}
