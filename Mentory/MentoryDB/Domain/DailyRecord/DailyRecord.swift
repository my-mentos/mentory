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


// MARK: Object
actor DailyRecord: Sendable {
    // MARK: core
    init(id: UUID) {
        self.id = id
    }
    nonisolated let id: UUID
    nonisolated let logger = Logger(subsystem: "MentoryDB.DailyRecord", category: "Domain")
    
    
    // MARK: state
    
    
    // MARK: action
    func delete() async {
        let contanier = MentoryDatabase.container
        let context = ModelContext(contanier)
        let id = self.id
        
        do {
            // 1) DailyRecord.Model 을 id 로 조회
            let descriptor = FetchDescriptor<DailyRecordModel>(
                predicate: #Predicate<DailyRecordModel> { $0.id == id }
            )
            
            if let target = try context.fetch(descriptor).first {
                context.delete(target)
                try context.save()
            } else {
                logger.error("⚠️ DailyRecord: 삭제할 모델을 찾지 못했습니다.")
                return
            }

        } catch {
            logger.error("❌ DailyRecord 삭제 실패: \(error)")
            return
        }
    }
    
    
    // MARK: value
    @Model
    final class DailyRecordModel {
        // MARK: core
        @Attribute(.unique) var id: UUID
        var recordDate: Date  // 일기가 속한 날짜 (오늘/어제/그제)
        var createdAt: Date

        var analyzedResult: String
        var emotion: Emotion
        
        @Relationship var suggestions: [DailySuggestionModel] = []

        init(id: UUID,
             recordDate: Date,
             createdAt: Date,
             analyzedResult: String,
             emotion: Emotion,
             suggestions: [DailySuggestionModel]) {
            self.id = id
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
}
