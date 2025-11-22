//
//  MentoryDB.swift
//  MentoryDB
//
//  Created by 김민우 on 11/21/25.
//
import Foundation
import SwiftData
import Values
import OSLog


// MARK: Object
actor MentoryDB: Sendable {
    // MARK: core
    init(id: String = "MentoryDB.UniqueKey.shared") {
        self.id = id
    }
    
    nonisolated let logger = Logger(subsystem: "MentoryDB.MentoryDB", category: "Domain")
    fileprivate static let container: ModelContainer = {
        do {
            return try ModelContainer(for: Model.self)
        } catch {
            fatalError("❌ MentoryDB ModelContainer 생성 실패: \(error)")
        }
    }()
    
    
    // MARK: state
    nonisolated public let id: String
    
    func setName(_ newName: String) {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        // sharedUUID 에 해당하는 Model을 찾거나, 없으면 새로 생성
       let descriptor = FetchDescriptor<Model>(
         predicate: #Predicate { $0.id == id }
       )
        
        let model: Model
        
        do {
            if let existing = try context.fetch(descriptor).first {
                logger.debug("MentoryDB를 찾았습니다.")
                model = existing
            } else {
                logger.debug("MentoryDB가 존재하지 않습니다. 새로운 MentoryDB를 생성합니다.")
                model = Model(id: self.id, userName: newName)
            }
        } catch {
            logger.error("MentoryDB 조회 오류: \(error)")
            return
        }
        
        
        do {
            context.insert(model)
            
            model.userName = newName
            try context.save()
            logger.debug("MentoryDB에 새로운 이름 \(newName)을 저장했습니다.")
        } catch {
            logger.error("MentoryDB 저장 오류: \(error)")
            return
        }
    }
    func getName() -> String? {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<Model>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            guard let model = try context.fetch(descriptor).first else {
                logger.error("저장소 내부에 MentoryDB가 존재하지 않아 nil을 반환합니다.")
                return nil
            }
            
            logger.debug("MentoryDB에서 이름을 조회했습니다.")
            return model.userName
        } catch {
            logger.error("MentoryDB 조회 오류: \(error)")
            return nil
        }
    }
    
    func getAllRecords() async -> [RecordData] {
        let context = ModelContext(MentoryDB.container)
        
        let descriptor = FetchDescriptor<Model>(
            predicate: #Predicate {
                $0.id == self.id
            }
        )
        
        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("MentoryDB가 존재하지 않아 빈배열을 반환합니다.")
                return []
            }
            
            let recordModels = db.records.sorted { $0.createdAt > $1.createdAt }
            let recordDatas = recordModels
                .map { model in
                    return model.toData()
                }
            
            return recordDatas
        } catch {
            logger.error("레코드 조회 오류: \(error)")
            return []
        }
    }
    func getTodayRecordDatas() async -> [RecordData] {
        let context = ModelContext(MentoryDB.container)
        
        let descriptor = FetchDescriptor<Model>(
            predicate: #Predicate { $0.id == self.id }
        )
        
        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("DB가 존재하지 않아 빈 배열을 반환합니다.")
                return []
            }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

            let recordDatas = db.records
                .filter { $0.createdAt >= today && $0.createdAt < tomorrow }
                .sorted { $0.createdAt > $1.createdAt }
                .map { $0.toData() }
            
            return recordDatas
        } catch {
            logger.error("TodayRecord 조회 오류: \(error)")
            return []
        }
    }
    func getRecords(from: Date, to: Date) -> [RecordData] {
        let context = ModelContext(MentoryDB.container)
        
        let descriptor = FetchDescriptor<Model>(
            predicate: #Predicate { $0.id == self.id }
        )
        
        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("DB가 존재하지 않아 빈 배열을 반환합니다.")
                return []
            }

            return db.records.filter {
                $0.createdAt >= from && $0.createdAt <= to
            }
            .sorted { $0.createdAt > $1.createdAt }
            .map { $0.toData() }

        } catch {
            logger.error("날짜 범위 조회 오류: \(error)")
            return []
        }
    }
    
    
    
    // MARK: value
    @Model
    final class Model {
        // MARK: core
        @Attribute(.unique) var id: String
        var userName: String
        
        @Relationship var records: [DailyRecord.Model] = []
        
        init(id: ID, userName: String) {
            self.id = id
            self.userName = userName
        }
    }
}


