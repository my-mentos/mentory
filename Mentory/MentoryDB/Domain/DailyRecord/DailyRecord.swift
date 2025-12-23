//
//  DailyRecord.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import SwiftData
import Values
import Foundation
import OSLog


// MARK: SwiftData Model
@Model
final class DailyRecordModel {
    // MARK: core
    @Attribute(.unique) var id: UUID = UUID()
    
    var ticketId: UUID
    
    var recordDate: Date  // 일기가 속한 날짜 (오늘/어제/그제)
    var createdAt: Date

    var analyzedResult: String
    var emotion: Emotion
    
    @Relationship var suggestions: [DailySuggestionModel] = []

    init(ticketId: UUID, recordDate: Date, createdAt: Date, analyzedResult: String, emotion: Emotion, suggestions: [DailySuggestionModel]) {
        self.ticketId = ticketId
        self.recordDate = recordDate
        self.createdAt = createdAt
        self.analyzedResult = analyzedResult
        self.emotion = emotion
        self.suggestions = suggestions
    }
    
    
    // MARK: operator
    func toData() -> RecordData {
        return .init(id: self.id,
                     recordDate: .init(recordDate),
                     createdAt: .init(createdAt),
                     analyzedResult: self.analyzedResult,
                     emotion: self.emotion)
    }
}


// MARK: Object
public actor DailyRecord: Sendable {
    // MARK: core
    init(id: UUID) {
        self.id = id
    }
    nonisolated let id: UUID
    nonisolated let logger = Logger(subsystem: "MentoryDB.DailyRecord", category: "Domain")
    
    
    // MARK: state
    
    
    // MARK: action
    public func getSuggestions() async -> [SuggestionData] {
        let context = ModelContext(MentoryDBReal.container)
        let recordId = self.id

        let descriptor = FetchDescriptor<DailyRecordModel>(
            predicate: #Predicate { $0.id == recordId }
        )

        do {
            guard let dailyRecord = try context.fetch(descriptor).first else {
                logger.error("getSuggestions: DailyRecord 조회 실패 >> [] 반환")
                return []
            }

            // DailySuggestionModel > SuggestionData 변환
            let suggestions: [SuggestionData] = dailyRecord.suggestions
                .map { $0.toData() }

            return suggestions

        } catch {
            logger.error("getSuggestions 오류: \(error)")
            return []
        }
    }

}
