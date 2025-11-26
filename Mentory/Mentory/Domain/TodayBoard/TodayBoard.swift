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
    
    @Published var todayString: String? = nil
    @Published var isFetchedTodayString: Bool = false
    @Published var actionKeyWordItems: [(String, Bool)] = []
    @Published var latestRecordId: UUID? = nil // 가장 최근 저장된 레코드 ID (행동 추천 업데이트용)
    
    
    // MARK: action
    func getIndicator() -> String {
        // 모든 레코드에서 행동 추천 수 합산
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
            let question = AlanLLM.Question("동기부여가 될만한 명언을 한가지를 말해줘!")
            let response = try await alanLLM.question(question)
            let mentoryDB = owner!.mentoryDB
            contentFromAlanLLM = response.content
            logger.debug("앨런성공: \(response.content)")
            
            _ = try await mentoryDB.saveMentorMessage(contentFromAlanLLM!, "Nangcheol")
            logger.debug("TodayBoard에서 saveMentorMessage() 호출완료")
            
            let currentMentorMessage = try await mentoryDB.fetchMentorMessage()
            logger.debug("mentoryDB에 저장된 최근 message내용: \(currentMentorMessage.message), 날짜: \(currentMentorMessage.createdAt), 캐릭터: \(currentMentorMessage.characterType.title)")
            
        } catch {
            logger.error("오늘의 명언 fetch 실패: \(error.localizedDescription)")
            return
        }
        
        // mutate
        self.todayString = contentFromAlanLLM
        self.isFetchedTodayString = true
    }
    
    func loadTodayMentorMessage() async {
        // capture
        let alanLLM = owner!.alanLLM
        let mentoryDB = owner!.mentoryDB
        
        do {
            // DB에서 최근 멘토메세지 가져오기
            let lastMessage = try await mentoryDB.fetchMentorMessage()
            logger.debug("DB 최근 멘토메세지: \(lastMessage.message) - 날짜: \(lastMessage.createdAt)")
            
            // 1.DB에 저장된 멘토메세지 없는 경우(nil)
            guard !lastMessage.message.isEmpty else {
                logger.debug("DB 저장값없음")
                
                // 1-1.새 멘토메세지 AlanLLM 호출
                let question = AlanLLM.Question("동기부여가 될만한 명언을 한가지를 말해줘!")
                let response = try await alanLLM.question(question)
                let content = response.content
                
                // 1-2.멘토메세지 저장할 랜덤 캐릭터 선택
                let character = Bool.random() ? "Nangcheol" : "Gureum"
                
                // 1-3.DB에 새 멘토메세지 저장
                try await mentoryDB.saveMentorMessage(content, character)
                logger.debug("최초 멘토메세지 저장 완료")
                
                // 1-4.저장 후 최신 멘토메세지 재조회
                let updatedMessage = try await mentoryDB.fetchMentorMessage()
                logger.debug("mentoryDB에 저장된 최근 message내용: \(updatedMessage.message), 날짜: \(updatedMessage.createdAt), 캐릭터: \(updatedMessage.characterType.title)")
                
                self.todayString = updatedMessage.message
                self.isFetchedTodayString = true
                return
            }
            
            // 2.최근 멘토메세지 생성일 == 오늘이라면 저장된 message사용
            guard !Calendar.current.isDateInToday(lastMessage.createdAt) else {
                logger.debug("멘토메세지가 최신화되어있음 message내용: \(lastMessage.message)")
                self.todayString = lastMessage.message
                self.isFetchedTodayString = true
                return
            }
            
            // 2-1.최근 멘토메세지 생성일 != 오늘이라면 새로운 명언 생성
            logger.debug("멘토메세지 최신화 아님 AlanLLM 요청 시작")
            
            let question = AlanLLM.Question("동기부여가 될만한 명언을 한가지를 말해줘!")
            let response = try await alanLLM.question(question)
            let content = response.content
            
            logger.debug("AlanLLM 응답 성공: \(content)")
            
            // 2-2.멘토메세지에 저장할 랜덤 캐릭터 선택
            let character = Bool.random() ? "Nangcheol" : "Gureum"
            
            // 2-3.DB에 새 멘토메세지 저장
            try await mentoryDB.saveMentorMessage(content, character)
            logger.debug("TodayBoard에서 saveMentorMessage() 호출완료/ 새로운 멘토메세지 저장")
            
            // 2-4. DB에서 최신 멘토메세지 다시 가져오기
            let updatedMessage = try await mentoryDB.fetchMentorMessage()
            logger.debug("최신 멘토메세지 업데이트: \(updatedMessage.message), 캐릭터: \(updatedMessage.characterType.title)")
            
            // mutate
            self.todayString = updatedMessage.message
            self.isFetchedTodayString = true
            
        } catch {
            logger.error("오늘의 명언 처리 실패: \(error.localizedDescription)")
            return
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
    }
}
