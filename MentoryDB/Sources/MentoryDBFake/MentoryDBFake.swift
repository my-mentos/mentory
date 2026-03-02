//
//  MentoryDBFake.swift
//  MentoryDB
//
//  Created by 김민우 on 12/23/25.
//
import Foundation
import Collections
import Values


// MARK: Object
@MainActor
public final class MentoryDatabaseFake: Sendable {
    // MARK: core
    public nonisolated init() { }
    
    // MARK: state
    public var userName: String? = nil
    public var userCharacter: MentoryCharacter? = nil
    public var message: MessageData? = nil
    
    private var createRecordQueue: Deque<RecordData> = []
    public func insertTicket(_ recordData: RecordData) {
        self.createRecordQueue.append(recordData)
    }
    
    public var records: [DailyRecordFake] = []
    public func getDailyRecord(ticketId: UUID) -> DailyRecordFake? {
        return records.first { dailyRecord in
            dailyRecord.ticketId == ticketId
        }
    }
    public func isSameDayRecordExist(_ date: MentoryDate) -> Bool {
        let result = self.records
            .contains { record in
                record.recordDate.isSameDate(as: date) == true
            }
        
        return result
    }
    public func getRecentRecord() -> DailyRecordFake? {
        return self.records
            .max(by: { $0.recordDate < $1.recordDate })
    }

    public func getCompletedSuggestionsCount() -> Int {
        return records.reduce(0) { total, record in
            total + record.suggestions.filter { $0.isDone }.count
        }
    }

    public func updateSuggestionStatus(targetId: UUID, isDone: Bool) {
        for record in records {
            if let suggestion = record.suggestions.first(where: { $0.id == targetId }) {
                suggestion.isDone = isDone
                return
            }
        }
    }

    // MARK: action
    public func createDailyRecords() {
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
