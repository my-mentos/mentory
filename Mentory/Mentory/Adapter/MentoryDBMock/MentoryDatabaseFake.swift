//
//  MentoryDBModel.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation
import Collections
import Values


// MARK: Object Model
@MainActor
final class MentoryDatabaseFake: Sendable {
    // MARK: core
    nonisolated init() { }
    
    // MARK: state
    var userName: String? = nil
    var userCharacter: MentoryCharacter? = nil
    var message: MessageData? = nil
    
    private var createRecordQueue: Deque<RecordData> = []
    func insertTicket(_ recordData: RecordData) {
        self.createRecordQueue.append(recordData)
    }
    
    var records: [DailyRecordFake] = []
    func getDailyRecord(ticketId: UUID) -> DailyRecordFake? {
        return records.first { dailyRecord in
            dailyRecord.ticketId == ticketId
        }
    }
    func isSameDayRecordExist(_ date: MentoryDate) -> Bool {
        let result = self.records
            .contains { record in
                record.recordDate.isSameDate(as: date) == true
            }
        
        return result
    }
    func getRecentRecord() -> DailyRecordFake? {
        return self.records
            .max(by: { $0.recordDate < $1.recordDate })
    }

    func getCompletedSuggestionsCount() -> Int {
        return records.reduce(0) { total, record in
            total + record.suggestions.filter { $0.isDone }.count
        }
    }

    // MARK: action
    func createDailyRecords() {
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
