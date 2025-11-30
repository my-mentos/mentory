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
final class MentoryDBModel: Sendable {
    // MARK: core
    nonisolated init() { }
    
    // MARK: state
    var userName: String? = nil
    
    var createRecordQueue: Deque<RecordData> = []
    
    var records: [DailyRecordModel] = []
    
//    var messages: [MessageData] = []
    
    var messages: [MentorMessageModel] = []
    
    func getAllRecords() -> [RecordData] {
        self.records
            .map {
                RecordData(id: $0.id,
                           createdAt: $0.createAt,
                           content: $0.content,
                           analyzedResult: $0.analyzedContent,
                           emotion: $0.emotion,
                           actionTexts: $0.actionTexts,
                           actionCompletionStatus: $0.actionCompletionStatus)
            }
    }
    func getTodayRecords() -> [RecordData] {
        let calendar = Calendar.current
        
        return self.records
            .filter { calendar.isDateInToday($0.createAt) }
            .map {
                RecordData(id: $0.id,
                           createdAt: $0.createAt,
                           content: $0.content,
                           analyzedResult: $0.analyzedContent,
                           emotion: $0.emotion,
                           actionTexts: $0.actionTexts,
                           actionCompletionStatus: $0.actionCompletionStatus)
            }
    }
    func getRecords(from: Date, to: Date) -> [RecordData] {
        let start = min(from, to)
        let end = max(from, to)
        
        return self.records
            .filter { $0.createAt >= start && $0.createAt <= end }
            .map {
                RecordData(id: $0.id,
                           createdAt: $0.createAt,
                           content: $0.content,
                           analyzedResult: $0.analyzedContent,
                           emotion: $0.emotion,
                           actionTexts: $0.actionTexts,
                           actionCompletionStatus: $0.actionCompletionStatus)
            }
    }
    
    
    // MARK: action
    func createDailyRecords() {
        // mutate
        while createRecordQueue.isEmpty == false {
            let data = createRecordQueue.removeFirst()
            
            let newRecord = DailyRecordModel(
                owner: self,
                createAt: data.createdAt,
                content: data.content,
                analyzedContent: data.analyzedResult,
                emotion: data.emotion,
                actionTexts: data.actionTexts,
                actionCompletionStatus: data.actionCompletionStatus
            )
            
            records.append(newRecord)
        }
    }

    func updateActionCompletion(recordId: UUID, completionStatus: [Bool]) {
        guard let record = records.first(where: { $0.id == recordId }) else {
            print("레코드 ID \(recordId)를 찾을 수 없습니다.")
            return
        }

        record.actionCompletionStatus = completionStatus
        print("레코드 \(recordId)의 행동 추천 완료 상태가 업데이트되었습니다.")
    }

    func getMentorMessage() -> MessageData{
        let latest = messages.max { $0.createdAt < $1.createdAt }!

        let latestData = MessageData(
            id: latest.id,
            createdAt: latest.createdAt,
            message: latest.message,
            characterType: latest.characterType
        )
        return latestData
        
    }
    func setMentorMessage(_ message: String, _ type: CharacterType) {
        let newMessage = MentorMessageModel(
            owner: self,
            createdAt: Date(),
            message: message,
            characterType: type
        )
        
        messages.append(newMessage)
    }
//
    // MARK: value
}
