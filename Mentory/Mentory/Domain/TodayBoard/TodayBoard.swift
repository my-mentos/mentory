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
    
    @Published var recordForm: RecordForm? = nil
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
    func setUpForm() {
        logger.debug("TodayBoard.setUp 호출")
        
        // capture
        guard self.recordForm == nil else {
            logger.error("이미 TodayBoard에 RecordForm이 존재합니다.")
            return
        }
        
        // mutate
        self.recordForm = RecordForm(owner: self)
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

        // Watch로 명언 전송
        if let quote = contentFromAlanLLM {
            WatchConnectivityManager.shared.updateTodayString(quote)
        }
    }
    
    // 데이터 쌓기 위한테스트용 함수, 추후 loadTodayMentorMessage()로 변경해야함
    func loadTodayMentorMessageTest() async {
        let alanLLM = owner!.alanLLM
        let mentoryDB = owner!.mentoryDB
        do {
            let character: CharacterType = Bool.random() ? .Nangcheol : .Gureum
            let question = AlanQuestion(character.question)
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
            try await mentoryDB.saveMentorMessage(newMessage, character)
            
            //
            
            //mutate
            // DB에 저장된 새 멘토메세지 불러오기
            if let updatedMessage = try await mentoryDB.fetchMentorMessage() {
                logger.debug("DB: 멘토메세지 업데이트되었습니다. 메세지: \(updatedMessage.message), 캐릭터: \(updatedMessage.characterType.title)")
                self.mentorMessage = updatedMessage
                self.mentorMessageDate = updatedMessage.createdAt

                // Watch로 멘토 메시지 전송
                WatchConnectivityManager.shared.updateMentorMessage(updatedMessage.message, character: updatedMessage.characterType.rawValue)

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
            let character: CharacterType = Bool.random() ? .Nangcheol : .Gureum
            let question = AlanQuestion(character.question)
            
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
            try await mentoryDB.saveMentorMessage(newMessage, character)
            
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
        }
        
        // mutate
    }
}
