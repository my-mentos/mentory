//
//  MentoryDBReal.swift
//  MentoryDB
//
//  Created by 김민우 on 11/21/25.
//
import Foundation
import SwiftData
import Values
import OSLog



// MARK: Object
public actor MentoryDBReal: Sendable {
    // MARK: core
    private init(id: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!) {
            self.id = id
            
            let context = ModelContext(Self.container)
            let descriptor = FetchDescriptor<MentoryDBModel>(
                predicate: #Predicate { $0.id == id }
            )
            
            do {
                let existing = try context.fetch(descriptor)
                
                // 이미 같은 id의 MentoryDBModel 이 있으면 아무 것도 하지 않음
                if existing.isEmpty {
                    let newModel = MentoryDBModel(id: id)
                    context.insert(newModel)
                    try context.save()
                    // 필요하면 여기서 logger로 "초기 DB 생성" 정도 남겨도 됨
                } else {
                    // 이미 존재 → 초기화 시 재생성하지 않음
                    // logger.debug("이미 MentoryDBModel 이 존재하므로 새로 생성하지 않습니다.")
                }
            } catch {
                fatalError("❌ MentoryDB 초기화 실패: \(error)")
            }
        }
    public static let shared = MentoryDBReal()
    
    nonisolated let logger = Logger(subsystem: "MentoryDB.MentoryDB", category: "Domain")
    static let container: ModelContainer = {
        do {
            return try ModelContainer(
                for: MentoryDBModel.self,
                RecordTicket.self,
                DailyRecordModel.self,
                DailySuggestionModel.self)
        } catch {
            fatalError("❌ MentoryDB ModelContainer 생성 실패: \(error)")
        }
    }()
    
    
    
    // MARK: state
    nonisolated public let id: UUID
    
    public func setName(_ newName: String) {
        let context = ModelContext(MentoryDBReal.container)
        
        let id = self.id
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            let model = try context.fetch(descriptor).first!
            context.insert(model)
            model.userName = newName
            
            try context.save()
            logger.debug("MentoryDB에 새로운 이름 \(newName)을 저장했습니다.")
        } catch {
            logger.error("MentoryDB 저장 오류: \(error)")
            return
        }
    }
    public func getName() -> String? {
        let context = ModelContext(MentoryDBReal.container)
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
    
    public func getMentorMessage() -> MessageData? {
        let context = ModelContext(MentoryDBReal.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("DB가 존재하지 않습니다.")
                return nil
            }
            
            guard let createdAt = db.messageCreatedAt,
                  let content = db.messageContent,
                  let character = db.messageCharacter else {
                logger.error("MentoryDB에 createAt, content, character 정보가 존재하지 않습니다.")
                return nil
            }
            
            let messageData = MessageData(
                createdAt: .init(createdAt),
                content: content,
                characterType: character)
            
            return messageData
            
        } catch {
            logger.error("DB fetch error → nil 반환")
            return nil
        }
    }
    public func setMentorMessage(_ data: MessageData) {
        let context = ModelContext(MentoryDBReal.container)
        let id = self.id
        
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        let db = try! context.fetch(descriptor).first!
        
        do {
            
            db.messageCreatedAt = data.createdAt.rawValue
            db.messageContent = data.content
            db.messageCharacter = data.characterType
            
            try context.save()
            logger.debug("MentoryDB에 MentorMessage를 업데이트했습니다.")
        } catch {
            logger.error("MentoryDB 저장 오류: \(error)")
            return
        }
    }
    
    public func getCharacter() -> MentoryCharacter? {
        let context = ModelContext(MentoryDBReal.container)
        
        let id = self.id
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        let model = try! context.fetch(descriptor).first!
        return model.userCharacter
    }
    public func setCharacter(_ character: MentoryCharacter) {
        let context = ModelContext(MentoryDBReal.container)
        
        let id = self.id
        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            let model = try context.fetch(descriptor).first!
            context.insert(model)
            model.userCharacter = character
            
            try context.save()
            logger.debug("MentoryDB에 새로운 캐릭터 \(character.rawValue) 저장했습니다.")
        } catch {
            logger.error("MentoryDB 저장 오류: \(error)")
            return
        }
    }
    
    public func getRecordCount() -> Int {
        let context = ModelContext(MentoryDBReal.container)
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
    
    public func isSameDayRecordExist(for date: MentoryDate) -> Bool {
        let context = ModelContext(MentoryDBReal.container)
        let id = self.id

        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("MentoryDB가 존재하지 않아 isSameDayRecordExist에서 false 반환")
                return false
            }

            let exists = db.records.contains { record in
                MentoryDate(record.recordDate).isSameDate(as: date)
            }
            logger.debug("isSameDayRecordExist: \(exists)")

            return exists
        } catch {
            logger.error("동일 날짜 레코드 조회 중 오류 발생: \(error)")
            return false
        }
    }

    public func getRecentRecord() -> DailyRecord? {
        let context = ModelContext(MentoryDBReal.container)
        let id = self.id

        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("MentoryDB가 존재하지 않아 getRecentRecord에서 nil 반환")
                return nil
            }

            // createdAt 기준 최신 DailyRecordModel 찾기
            guard let latest = db.records.max(by: { $0.recordDate < $1.recordDate }) else {
                logger.debug("getRecentRecord: DailyRecord가 존재하지 않아 nil 반환")
                return nil
            }

            // DailyRecordModel → RecordData 변환
            return DailyRecord(id: latest.id)

        } catch {
            logger.error("최근 DailyRecord 조회 중 오류 발생: \(error)")
            return nil
        }
    }
    
    public func getRecords() -> [RecordData] {
        let context = ModelContext(MentoryDBReal.container)
        let id = self.id

        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("MentoryDB가 존재하지 않아 getRecords에서 [] 반환")
                return []
            }

            let sorted = db.records.sorted(by: { $0.recordDate > $1.recordDate })
            return sorted.map { $0.toData() }
        } catch {
            logger.error("getRecords 조회 중 오류 발생: \(error)")
            return []
        }
    }
    

    public func getCompletedSuggestionsCount() -> Int {
        let context = ModelContext(MentoryDBReal.container)
        let id = self.id

        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("MentoryDB가 존재하지 않아 getCompletedSuggestionsCount에서 0 반환")
                return 0
            }

            // 모든 DailyRecord의 완료된 Suggestion 개수 카운트
            let completedCount = db.records.reduce(0) { total, record in
                total + record.suggestions.filter { $0.status == true }.count
            }

            logger.debug("완료된 제안 개수: \(completedCount)")
            return completedCount

        } catch {
            logger.error("완료된 제안 개수 조회 중 오류 발생: \(error)")
            return 0
        }
    }

    public func updateSuggestionStatus(targetId: UUID, isDone: Bool) {
        let context = ModelContext(MentoryDBReal.container)
        let id = self.id

        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            guard let db = try context.fetch(descriptor).first else {
                logger.error("MentoryDB가 존재하지 않아 updateSuggestionStatus 실패")
                return
            }

            // 모든 DailyRecord의 Suggestion 중에서 target이 일치하는 것 찾기
            for record in db.records {
                if let suggestion = record.suggestions.first(where: { $0.target == targetId }) {
                    suggestion.status = isDone
                    try context.save()
                    logger.debug("Suggestion(target: \(targetId)) 상태 업데이트: \(isDone)")
                    return
                }
            }

            logger.warning("targetId \(targetId)에 해당하는 Suggestion을 찾지 못했습니다.")

        } catch {
            logger.error("Suggestion 상태 업데이트 중 오류 발생: \(error)")
        }
    }

    public func getRecord(ticketId: UUID) -> DailyRecord? {
        fatalError("구현 예정입니다.")
    }
    public func insertTicket(_ recordData: RecordData) {
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
    
    
    public func insertSuggestions(ticketId: UUID, suggestions: [SuggestionData]) async {
        let context = ModelContext(MentoryDBReal.container)
        let id = self.id

        let descriptor = FetchDescriptor<MentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            // 1) 나(MentoryDBReal)에 해당하는 MentoryDBModel 찾기
            guard let db = try context.fetch(descriptor).first else {
                logger.error("insertSuggestions: MentoryDBModel not found")
                return
            }

            // 2) ticketId 로 DailyRecordModel 찾기
            guard let record = db.records.first(where: { $0.ticketId == ticketId }) else {
                logger.error("insertSuggestions: DailyRecordModel not found for ticketId \(ticketId)")
                return
            }

            // 3) SuggestionData -> DailySuggestionModel 매핑해서 record에 붙이기
            for item in suggestions {
                let model = DailySuggestionModel(
                    id: item.id,
                    target: item.target.rawValue,  // SuggestionID의 원시값(UUID)
                    content: item.content,
                    status: item.isDone
                )
                record.suggestions.append(model)
            }
            
            try context.save()
            logger.debug("insertSuggestions: \(suggestions.count)개의 DailySuggestionModel 저장 완료")
            
        } catch {
            logger.error("insertSuggestions failed: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    // MARK: action
    public func createDailyRecords() async {
        let context = ModelContext(MentoryDBReal.container)
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
                DailyRecordModel(
                    ticketId: data.id,
                    
                    recordDate: data.recordDate,
                    createdAt: data.createdAt,
                    
                    analyzedResult: data.analyzedResult,
                    emotion: data.emotion,
                    
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

            // 변환된 레코드의 분석 결과 로깅(추후 추천 로직 구현 시 삭제)
            for model in newModels {
                logger.debug("저장된 분석 결과 - 날짜: \(model.recordDate), 감정: \(model.emotion.rawValue), 메시지: \(model.analyzedResult, privacy: .public)")
            }


        } catch {
            logger.error("큐 플러시 중 오류 발생: \(error.localizedDescription)")
        }
    }
}


// MARK: model
@Model
final class MentoryDBModel {
    // MARK: core
    @Attribute(.unique) var id: UUID
    var userName: String? = nil
    
    var userCharacter: MentoryCharacter? = nil
    
    var messageCreatedAt: Date? = nil
    var messageContent: String? = nil
    var messageCharacter: MentoryCharacter? = nil
    
    @Relationship var createRecordQueue: [RecordTicket] = []
    @Relationship var records: [DailyRecordModel] = []
    
    
    init(id: UUID,
         userName: String? = nil) {
        self.id = id
        self.userName = userName
    }
}

@Model
final class RecordTicket {
    @Attribute(.unique) var id: UUID
    
    var recordDate: Date  // 일기가 속한 날짜
    var createdAt: Date   // 실제 작성 시간
    
    var analyzedResult: String
    var emotion: Emotion
    
    init(data: RecordData) {
        self.id = data.id
        self.recordDate = data.recordDate.rawValue
        self.createdAt = data.createdAt.rawValue
        self.analyzedResult = data.analyzedResult
        self.emotion = data.emotion
    }
    
    func toRecordData() -> RecordData {
        .init(
            id: id,
            recordDate: .init(recordDate),
            createdAt: .init(createdAt),
            analyzedResult: analyzedResult,
            emotion: emotion,
        )
    }
}





