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
        var createdAt: Date
        
        var content: String
        var analyzedResult: String
        var emotion: Emotion
        
        init(id: UUID = UUID(), createdAt: Date, content: String, analyzedResult: String, emotion: Emotion) {
            self.id = id
            self.createdAt = createdAt
            self.content = content
            self.analyzedResult = analyzedResult
            self.emotion = emotion
        }
        
        
        // MARK: operator
        func toData() -> RecordData {
            return .init(id: self.id,
                         createdAt: self.createdAt,
                         content: self.content,
                         analyzedResult: self.analyzedResult,
                         emotion: self.emotion)
        }
    }
}
