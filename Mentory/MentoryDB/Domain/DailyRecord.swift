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
        let contanier = MentoryDB.container
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
        var createdAt: Date   // 실제 작성 시간

        var content: String
        var analyzedResult: String
        var emotion: Emotion

        // 행동 추천 (무조건 3개)
        var actionTexts: [String]
        var actionCompletionStatus: [Bool]

        init(id: UUID = UUID(), recordDate: Date, createdAt: Date, content: String, analyzedResult: String, emotion: Emotion, actionTexts: [String] = [], actionCompletionStatus: [Bool] = []) {
            self.id = id
            self.recordDate = recordDate
            self.createdAt = createdAt
            self.content = content
            self.analyzedResult = analyzedResult
            self.emotion = emotion
            self.actionTexts = actionTexts
            self.actionCompletionStatus = actionCompletionStatus
        }
        
        
        // MARK: operator
        func toData() -> RecordData {
            return .init(id: self.id,
                         recordDate: self.recordDate,
                         createdAt: self.createdAt,
                         content: self.content,
                         analyzedResult: self.analyzedResult,
                         emotion: self.emotion,
                         actionTexts: self.actionTexts,
                         actionCompletionStatus: self.actionCompletionStatus)
        }
    }
}
