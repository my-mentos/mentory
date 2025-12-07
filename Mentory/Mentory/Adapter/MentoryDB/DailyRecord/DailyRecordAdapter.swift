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
    private let db: any MentoryDBInterface

    public init(recordData: RecordData, db: any MentoryDBInterface) {
        self.recordData = recordData
        self.db = db
    }

    @concurrent func getSuggestions() async throws -> [SuggestionData] {
        //fatalError("구현 예정입니다.")
        try await db.getSuggestions(by: recordData.id)
    }
}
