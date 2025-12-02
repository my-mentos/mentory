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
    init(id: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!) {
        self.id = id
    }
    
    nonisolated let logger = Logger(subsystem: "MentoryDB.MentoryDB", category: "Domain")
    static let container: ModelContainer = {
        do {
            return try ModelContainer(
                for: MentoryDB.MentoryDBModel.self, DailyRecord.DailyRecordModel.self,
                DailySuggestion.DailySuggestionModel.self)
        } catch {
            fatalError("❌ MentoryDB ModelContainer 생성 실패: \(error)")
        }
    }()
    
    
    
    // MARK: state
    // + id: UUID
    nonisolated public let id: UUID
    
    // + userName: String? = nil
    func setName(_ newName: String) {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        // sharedUUID 에 해당하는 Model을 찾거나, 없으면 새로 생성
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        let model: MentoryDBModel
        
        do {
            if let existing = try context.fetch(descriptor).first {
                logger.debug("MentoryDB를 찾았습니다.")
                model = existing
            } else {
                logger.debug("MentoryDB가 존재하지 않습니다. 새로운 MentoryDB를 생성합니다.")
                model = MentoryDBModel(id: self.id, userName: newName)
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
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
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
    
    // + records: [DailyRecord]
    func getAllRecords() async -> [RecordData] {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate {
                $0.id == id
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
            
            logger.debug("모든 레코드 조회 성공 \(recordDatas.count)")
            return recordDatas
        } catch {
            logger.error("레코드 조회 오류: \(error)")
            return []
        }
    }
    func getTodayRecordDatas() async -> [RecordData] {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
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
            
            logger.debug("오늘 레코드 조회 성공 \(recordDatas.count)")
            return recordDatas
        } catch {
            logger.error("TodayRecord 조회 오류: \(error)")
            return []
        }
    }
    func getRecords(from: Date, to: Date) -> [RecordData] {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
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
    func getRecordCount() -> Int {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("MentoryDB가 존재하지 않아 0을 반환합니다.")
                return 0
            }
            
            return db.records.count
            
        } catch {
            logger.error("에러 발생으로 0 반환. \(error)")
            return 0
        }
    }
    
    // + createRecordQueue: [RecordTicket]
    func insertDataInQueue(_ recordData: RecordData) {
        let context = ModelContext(Self.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate {
                $0.id == id
            }
        )
        
        do {
            if let db = try context.fetch(descriptor).first {
                let ticket = RecordTicket(data: recordData)
                
                db.createRecordQueue.append(ticket)
                logger.debug("RecordData를 큐에 추가했습니다. 현재 큐 크기: \(db.createRecordQueue.count)")
            } else {
                logger.debug("MentoryDB가 존재하지 않습니다. 새로운 MentoryDB를 생성한 뒤 큐에 추가합니다.")
                let newDb = MentoryDBModel(id: id, userName: nil)
                context.insert(newDb)
            }
            
            try context.save()
        } catch {
            logger.error("RecordData 큐 추가 오류: \(error.localizedDescription)")
            return
        }
    }
    
    // + mentorMessages: MentorMessage? = nil
    func getMentorMessage() -> MessageData? {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("DB가 존재하지 않습니다.")
                return nil
            }
            
            // messages가 비어있을 때
            guard let latest = db.messages.max(by: { $0.createdAt < $1.createdAt }) else {
                logger.error("messages가 비어 있습니다.")
                return nil
            }
            logger.debug("저장된 전체 메세지:\(db.messages.sorted(by: { $0.createdAt < $1.createdAt }).map { $0.toMessageData() })")
            return latest.toMessageData()
            
        } catch {
            logger.error("DB fetch error → nil 반환")
            return nil
        }
    }
    func setMentorMessage(_ message: String, _ type: MentoryCharacter) {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("DB가 존재하지 않아 메세지를 저장할수 없습니다.")
                return
            }

            let newMessage = MentorMessage.MentorMessageModel(
                id: UUID(),
                createdAt: Date(),
                message: message,
                characterType: type
            )
            
            db.messages.append(newMessage)
            try context.save()
            logger.debug("MentoryDB에 새로운 멘토 메시지를 저장했습니다.")
            
        } catch {
            logger.error("MentoryDB 저장 오류: \(error)")
            return
        }
    }
    
    
    
    // MARK: other
    func updateActionCompletion(recordId: UUID, completionStatus: [Bool]) async {
        let context = ModelContext(MentoryDB.container)
        
        let descriptor = FetchDescriptor<DailyRecord.DailyRecordModel>(
            predicate: #Predicate<DailyRecord.DailyRecordModel> { $0.id == recordId }
        )
        
        do {
            guard let record = try context.fetch(descriptor).first else {
                logger.error("레코드 ID \(recordId)를 찾을 수 없습니다.")
                return
            }
            
            record.actionCompletionStatus = completionStatus
            try context.save()
            
            logger.debug("레코드 \(recordId)의 행동 추천 완료 상태가 업데이트되었습니다.")
        } catch {
            logger.error("행동 추천 완료 상태 업데이트 실패: \(error)")
        }
    }

    /// 특정 날짜의 일기를 조회합니다 (recordDate 기준)
    func getRecordForDate(_ targetDate: Date) async -> RecordData? {
        let context = ModelContext(MentoryDB.container)
        let id = self.id

        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("DB가 존재하지 않아 nil을 반환합니다.")
                return nil
            }

            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: targetDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let record = db.records.first {
                let recordStart = calendar.startOfDay(for: $0.recordDate)
                return recordStart >= startOfDay && recordStart < endOfDay
            }

            if let record = record {
                logger.debug("날짜 \(targetDate)의 레코드 조회 성공")
                return record.toData()
            } else {
                logger.debug("날짜 \(targetDate)의 레코드가 없습니다.")
                return nil
            }
        } catch {
            logger.error("특정 날짜 레코드 조회 오류: \(error)")
            return nil
        }
    }

    /// 특정 RecordDate(오늘/어제/그제)에 일기가 있는지 확인합니다
    func hasRecordForDate(_ recordDate: RecordDate) async -> Bool {
        let targetDate = recordDate.toDate()
        let record = await getRecordForDate(targetDate)
        return record != nil
    }

    /// 작성 가능한 날짜 목록을 반환합니다 (일기가 없는 날짜만)
    func getAvailableDatesForWriting() async -> [RecordDate] {
        var available: [RecordDate] = []

        for date in RecordDate.allCases {
            if await !hasRecordForDate(date) {
                available.append(date)
            }
        }

        logger.debug("작성 가능한 날짜: \(available.map { $0.rawValue })")
        return available
    }


    
    
    
    // MARK: action
    func createDailyRecords() async {
        let context = ModelContext(MentoryDB.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("DB가 존재하지 않아 큐를 플러시할 수 없습니다.")
                return
            }
            
            guard db.createRecordQueue.isEmpty == false else {
                logger.debug("큐에 변환할 RecordData가 없습니다.")
                return
            }
            
            // 1) 새 레코드 생성
            let newModels = db.createRecordQueue.map { data in
                DailyRecord.DailyRecordModel(
                    id: data.id,
                    
                    recordDate: data.recordDate,
                    createdAt: data.createdAt,
                    
                    analyzedResult: data.analyzedResult,
                    emotion: data.emotion,
                    
                    actionTexts: data.actionTexts,
                    actionCompletionStatus: data.actionCompletionStatus,
                    suggestions: []
                )
            }
            
            // 2) 관계 추가 (insert는 SwiftData가 자동 처리)
            for model in newModels {
                db.records.append(model)
            }
            
            // 3) 큐 비우기
            db.createRecordQueue.removeAll()
            
            // 4) 단일 save()로 트랜잭션 처리
            try context.save()
            
            logger.debug("RecordData \(newModels.count)개를 DailyRecord로 변환했습니다.")
            
        } catch {
            logger.error("큐 플러시 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    // MARK: value
    @Model
    final class MentoryDBModel {
        // MARK: core
        @Attribute(.unique) var id: UUID
        var userName: String?
        
        @Relationship var createRecordQueue: [RecordTicket] = []
        @Relationship var records: [DailyRecord.DailyRecordModel] = []
        
        @Relationship var messages: [MentorMessage.MentorMessageModel] = []
        
        init(id: ID, userName: String?) {
            self.id = id
            self.userName = userName
        }
    }
    
    @Model
    final class RecordTicket {
        // MARK: core
        @Attribute(.unique) var id: UUID
        var recordDate: Date  // 일기가 속한 날짜
        var createdAt: Date   // 실제 작성 시간
        
        var analyzedResult: String
        var emotion: Emotion
        
        var actionTexts: [String]
        var actionCompletionStatus: [Bool]
        
        init(data: RecordData) {
            self.id = data.id
            self.recordDate = data.recordDate
            self.createdAt = data.createdAt
            self.analyzedResult = data.analyzedResult
            self.emotion = data.emotion
            self.actionTexts = data.actionTexts
            self.actionCompletionStatus = data.actionCompletionStatus
        }
        
        func toRecordData() -> RecordData {
            .init(
                id: id,
                recordDate: recordDate,
                createdAt: createdAt,
                analyzedResult: analyzedResult,
                emotion: emotion,
                actionTexts: actionTexts,
                actionCompletionStatus: actionCompletionStatus
            )
        }
    }
    
}


