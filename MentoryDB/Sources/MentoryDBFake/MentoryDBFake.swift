//
//  MentoryDBFake.swift
//  MentoryDB
//
//  Created by 김민우 on 12/23/25.
//
import Foundation
import Collections
import Values


// MARK: Object Model
@MainActor
package final class MentoryDatabaseFake: Sendable {
    // MARK: core
    package nonisolated init() { }
    
    // MARK: state
    package var userName: String? = nil
    package var userCharacter: MentoryCharacter? = nil
    package var message: MessageData? = nil
    
    private var createRecordQueue: Deque<RecordData> = []
    package func insertTicket(_ recordData: RecordData) {
        self.createRecordQueue.append(recordData)
    }
    
    package var records: [DailyRecordFake] = []
    package func getDailyRecord(ticketId: UUID) -> DailyRecordFake? {
        return records.first { dailyRecord in
            dailyRecord.ticketId == ticketId
        }
    }
    package func isSameDayRecordExist(_ date: MentoryDate) -> Bool {
        let result = self.records
            .contains { record in
                record.recordDate.isSameDate(as: date) == true
            }
        
        return result
    }
    package func getRecentRecord() -> DailyRecordFake? {
        return self.records
            .max(by: { $0.recordDate < $1.recordDate })
    }

    package func getCompletedSuggestionsCount() -> Int {
        return records.reduce(0) { total, record in
            total + record.suggestions.filter { $0.isDone }.count
        }
    }

    package func updateSuggestionStatus(targetId: UUID, isDone: Bool) {
        for record in records {
            if let suggestion = record.suggestions.first(where: { $0.id == targetId }) {
                suggestion.isDone = isDone
                return
            }
        }
    }

    // MARK: action
    package func createDailyRecords() {
        // mutate
        while createRecordQueue.isEmpty == false {
            let recordData = createRecordQueue.removeFirst()
            
            let newRecord = DailyRecordFake(
                owner: self,
                ticketId: recordData.id,
                recordDate: recordData.recordDate,
                createAt: recordData.createdAt,
                analyzedContent: recordData.analyzedResult,
                emotion: recordData.emotion
            )
            
            records.append(newRecord)
        }
    }
    

    // MARK: value
}

