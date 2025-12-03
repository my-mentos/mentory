//
//  TodayBoard.swift
//  Mentory
//
//  Created by SJS, 구현모 on 11/14/25.
//
import Foundation
import Combine
import Values
import OSLog


// MARK: Object
@MainActor
final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryiOS?

    @Published var recordForm: RecordForm? = nil  // deprecated: 기존 단일 폼 (호환성 유지)
    @Published var recordForms: [RecordForm] = []  // RecordForm 배열 (각 RecordForm이 targetDate 정보를 포함)

    @Published var records: [RecordData] = []
    func getIndicator() -> String {
        let records = self.records
        
        let totalActions = records.reduce(0) { $0 + $1.actionTexts.count }
        let completedActions = records.reduce(0) { sum, record in
            sum + record.actionCompletionStatus.filter { $0 }.count
        }
        return "\(completedActions)/\(totalActions)"
    }
    func getProgress() -> Double {
        // 모든 레코드에서 행동 완료율 계산
        let totalActions = records.reduce(0) { $0 + $1.actionTexts.count }
        guard totalActions > 0 else { return 0 }
        let completedActions = records.reduce(0) { sum, record in
            sum + record.actionCompletionStatus.filter { $0 }.count
        }
        return Double(completedActions) / Double(totalActions)
    }
    
    @Published var mentorMessage: MessageData?
    @Published var mentorMessageDate: Date?
    
    @Published var todayString: String? = nil
    @Published var isFetchedTodayString: Bool = false
    
    @Published var actionKeyWordItems: [(String, Bool)] = []
    @Published var latestRecordId: UUID? = nil // 가장 최근 저장된 레코드 ID (행동 추천 업데이트용)
    
    
    // MARK: action
    /// @deprecated 이 메서드는 더 이상 사용되지 않습니다.
    /// 대신 setupRecordForms()와 날짜 선택 UI를 사용하세요.
    /// 기존 호환성 유지를 위해 남겨둔 메서드입니다.
    func setUpForm() {
        logger.warning("setUpForm() 호출됨 - deprecated: setupRecordForms() 사용을 권장합니다")

        // capture
        guard self.recordForm == nil else {
            logger.error("이미 TodayBoard에 RecordForm이 존재합니다.")
            return
        }

        // mutate - 기본값으로 오늘 날짜 사용
        self.recordForm = RecordForm(owner: self, targetDate: .today)
    }
    
    func fetchTodayString() async {
        // capture
        guard isFetchedTodayString == false else {
            logger.error("오늘의 명언이 이미 fetch되었습니다.")
            return
        }
        let alanLLM = owner!.alanLLM
        
        // process
        let contentFromAlanLLM: String?
        do {
            // Alan API를 통해 오늘의 명언 또는 속담 요청
            let question = AlanQuestion("오늘의 명언이나 속담을 하나만 짧게 알려줘. 명언이나 속담만 답변해줘.")
            let response = try await alanLLM.question(question)
            
            // watch 앱으로 데이터 전송
            
            contentFromAlanLLM = response.content
            logger.debug("오늘의 명언 fetch 성공: \(response.content)")
        } catch {
            logger.error("오늘의 명언 fetch 실패: \(error.localizedDescription)")
            return
        }
        
        // mutate
        self.todayString = contentFromAlanLLM
        self.isFetchedTodayString = true


    }
    
    // 데이터 쌓기 위한테스트용 함수, 추후 loadTodayMentorMessage()로 변경해야함
    func loadTodayMentorMessageTest() async {
        let alanLLM = owner!.alanLLM
        let mentoryDB = owner!.mentoryDB
        do {
            let randomCharacter = MentoryCharacter.random
            let question = AlanQuestion(randomCharacter.question)
            let NewMessageFromAlanLLM: String?
            do {
                //AlanLLM 호출
                logger.debug("AlanLLM: 멘토메세지 요청합니다.")
                let response = try await alanLLM.question(question)
                NewMessageFromAlanLLM = response.content
                logger.debug("AlanLLM: 멘토메세지 요청성공: \(response.content)")
            } catch {
                logger.error("AlanLLM: 멘토메세지 요청실패: \(error.localizedDescription)")
                return
            }
            guard let newMessage = NewMessageFromAlanLLM else {
                logger.error("AlanLLM: nil을 반환")
                return
            }
            // AlanLLM 호출결과값 DB에 저장
            try await mentoryDB.saveMentorMessage(newMessage, randomCharacter)
            
            //
            
            //mutate
            // DB에 저장된 새 멘토메세지 불러오기
            if let updatedMessage = try await mentoryDB.fetchMentorMessage() {
                logger.debug("DB: 멘토메세지 업데이트되었습니다. 메세지: \(updatedMessage.message), 캐릭터: \(updatedMessage.characterType.title)")
                self.mentorMessage = updatedMessage
                self.mentorMessageDate = updatedMessage.createdAt

                // Watch로 멘토 메시지 전송
                await WatchConnectivityManager.shared.updateMentorMessage(updatedMessage.message, character: updatedMessage.characterType.rawValue)

                return
            }
        } catch {
            logger.error("loadTodayMentorMessage()처리 실패: \(error.localizedDescription)")
        }
    }
    func loadTodayMentorMessage() async {
        // capture
        let alanLLM = owner!.alanLLM
        let mentoryDB = owner!.mentoryDB
        do {
            // DB에서 최신 멘토메세지 가져오기
            if let lastMessage = try await mentoryDB.fetchMentorMessage(),
               Calendar.current.isDateInToday(lastMessage.createdAt) {
                
                // DB의 멘토메세지가 최신화 되어있을경우 return
                logger.debug("DB: 멘토메세지가 최신입니다. 메세지: \(lastMessage.message), 캐릭터: \(lastMessage.characterType.title)")
                self.mentorMessage = lastMessage
                self.mentorMessageDate = lastMessage.createdAt
                return
            }
            
            // process
            // DB의 멘토메세지 nil이거나 최신화 되어있지 않은 경우
            logger.debug("DB: 멘토메세지가 nil이거나, 최신화되어있지않습니다.")
            
            // 새 멘토메세지 받을 캐릭터 랜덤선정
            let randomCharacter = MentoryCharacter.random
            let question = AlanQuestion(randomCharacter.question)
            
            let NewMessageFromAlanLLM: String?
            do {
                //AlanLLM 호출
                logger.debug("AlanLLM: 멘토메세지 요청합니다.")
                let response = try await alanLLM.question(question)
                NewMessageFromAlanLLM = response.content
                logger.debug("AlanLLM: 멘토메세지 요청성공: \(response.content)")
            } catch {
                logger.error("AlanLLM: 멘토메세지 요청실패: \(error.localizedDescription)")
                return
            }
            guard let newMessage = NewMessageFromAlanLLM else {
                logger.error("AlanLLM: nil을 반환")
                return
            }
            // AlanLLM 호출결과값 DB에 저장
            try await mentoryDB.saveMentorMessage(newMessage, randomCharacter)
            
            //mutate
            // DB에 저장된 새 멘토메세지 불러오기
            if let updatedMessage = try await mentoryDB.fetchMentorMessage() {
                logger.debug("DB: 멘토메세지 업데이트되었습니다. 메세지: \(updatedMessage.message), 캐릭터: \(updatedMessage.characterType.title)")
                self.mentorMessage = updatedMessage
                self.mentorMessageDate = updatedMessage.createdAt
                return
            }
        } catch {
            logger.error("loadTodayMentorMessage()처리 실패: \(error.localizedDescription)")
        }
    }
    
    func loadTodayRecords() async {
        // capture
        let mentoryDB = owner!.mentoryDB
        
        // process
        let todayRecords: [RecordData]
        
        do {
            todayRecords = try await mentoryDB.fetchToday()
            logger.info("오늘의 레코드 \(todayRecords.count)개 로드 성공")
        } catch {
            logger.error("레코드 로드 실패: \(error)")
            return
        }
        
        // mutate
        self.records = todayRecords
        
        // 가장 최근 레코드의 행동 추천을 actionKeyWordItems에 로드
        if let lastRecord = todayRecords.max(by: { $0.createdAt < $1.createdAt }) {
            self.actionKeyWordItems = zip(lastRecord.actionTexts, lastRecord.actionCompletionStatus).map { ($0, $1) }
            self.latestRecordId = lastRecord.id
            
            logger.debug("가장 최근 레코드의 행동 추천 \(lastRecord.actionTexts.count)개 로드")

            // Watch로 행동 추천 투두 전송
            await WatchConnectivityManager.shared.updateActionTodos(
                lastRecord.actionTexts,
                completionStatus: lastRecord.actionCompletionStatus
            )
        }
    }
    func updateActionCompletion() async {
        // capture
        guard let recordId = latestRecordId else {
            logger.error("업데이트할 레코드 ID가 없습니다.")
            return
        }
        let mentoryDB = owner!.mentoryDB
        let completionStatus = actionKeyWordItems.map { $0.1 }
        
        // process
        do {
            try await mentoryDB.updateActionCompletion(recordId: recordId, completionStatus: completionStatus)
            logger.debug("행동 추천 완료 상태가 업데이트되었습니다.")
        } catch {
            logger.error("행동 추천 완료 상태 업데이트 실패: \(error)")
            return
        }
        
        // mutate
        // Watch로 업데이트된 완료 상태 전송
        let todos = actionKeyWordItems.map { $0.0 }
        await WatchConnectivityManager.shared.updateActionTodos(todos, completionStatus: completionStatus)
    }

    /// 작성 가능한 날짜의 RecordForm들을 생성합니다
    func setupRecordForms() async {
        // capture
        let mentoryDB = owner!.mentoryDB

        // process
        let availableDates: [RecordDate]
        do {
            availableDates = try await mentoryDB.fetchAvailableDatesForWriting()
            logger.debug("작성 가능한 날짜 \(availableDates.count)개 발견")
        } catch {
            logger.error("작성 가능한 날짜 조회 실패: \(error)")
            return
        }

        // mutate
        guard !availableDates.isEmpty else {
            logger.warning("작성 가능한 날짜가 없습니다. 모든 날짜에 이미 일기가 작성되었습니다.")
            self.recordForms = []
            return
        }

        self.recordForms = availableDates.map { date in
            RecordForm(owner: self, targetDate: date)
        }

        logger.debug("RecordForm \(availableDates.count)개 생성 완료")
    }

    /// 지정된 날짜의 RecordForm을 반환합니다
    func getRecordForm(for date: RecordDate) -> RecordForm? {
        return recordForms.first { $0.targetDate == date }
    }

    /// Watch로부터 투두 완료 처리를 받아서 DB 업데이트
    func handleWatchTodoCompletion(todoText: String, isCompleted: Bool) async {
        // capture
        guard let recordId = latestRecordId else {
            logger.error("업데이트할 레코드 ID가 없습니다.")
            return
        }

        // 투두 텍스트로 인덱스 찾기
        guard let index = actionKeyWordItems.firstIndex(where: { $0.0 == todoText }) else {
            logger.error("투두를 찾을 수 없음: \(todoText)")
            return
        }

        // process
        // UI 상태 업데이트
        actionKeyWordItems[index].1 = isCompleted
        logger.debug("Watch로부터 투두 완료 상태 업데이트: \(todoText) = \(isCompleted)")

        // records 배열에서도 업데이트 (인디케이터 반영용, 로직 개선 필요)
        if let recordIndex = records.firstIndex(where: { $0.id == recordId }) {
            let oldRecord = records[recordIndex]
            var newCompletionStatus = oldRecord.actionCompletionStatus
            newCompletionStatus[index] = isCompleted

            let updatedRecord = RecordData(
                id: oldRecord.id,
                recordDate: oldRecord.recordDate,
                createdAt: oldRecord.createdAt,
                content: oldRecord.content,
                analyzedResult: oldRecord.analyzedResult,
                emotion: oldRecord.emotion,
                actionTexts: oldRecord.actionTexts,
                actionCompletionStatus: newCompletionStatus
            )
            records[recordIndex] = updatedRecord
            logger.debug("records 배열 업데이트 완료 - 인디케이터가 반영됩니다.")
        }

        // DB 업데이트
        let mentoryDB = owner!.mentoryDB
        let completionStatus = actionKeyWordItems.map { $0.1 }

        do {
            try await mentoryDB.updateActionCompletion(recordId: recordId, completionStatus: completionStatus)
            logger.debug("Watch 투두 완료 상태가 DB에 저장되었습니다.")
        } catch {
            logger.error("Watch 투두 완료 상태 DB 저장 실패: \(error)")
        }
    }
}
