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
    
    // mentorMessage
    @Published var mentorMessage: MentorMessage? = nil

    // recordForm
    @Published var recordForms: [RecordForm] = []
    @Published var recordFormSelection: RecordForm? = nil
    
    @Published var recordCount: Int? = nil
    
    // suggestion
    @Published var suggestions: [Suggestion] = []
    
    
    // MARK: action
    func setUpMentorMessage() async {
        // capture
        let mentoryiOS = self.owner!
        
        let mentoryDB = mentoryiOS.mentoryDB // SwiftData에서 저장된 MentorMessage를 조회하기 위해 필요
        let alanLLM = mentoryiOS.alanLLM
        
        // process
        let messageContent: String
        do {
            // SwiftData에 저장된 MentorMessage를 불러온다.
            // 만약 없다면 -> 새로 갱신
            // 있는데, 유효하다면 -> 기존 거 재사용
            // 있는데, 지났다면 -> 새로 갱신
            let randomCharacter = MentoryCharacter.random
            let question = AlanQuestion(randomCharacter.question)
            
            let answer = try await alanLLM.question(question)
            messageContent = answer.content
        } catch {
            logger.error("setUpMentorMessage 에러 발생 : \(error)")
            return
        }
        
        // mutate
        self.mentorMessage = MentorMessage(
            owner: self,
            content: messageContent)
    }
    func setupRecordForms() async {
        // capture
        let mentoryDB = owner!.mentoryDB

        // process
        let availableDates: [MentoryDate]
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
    func setUpSuggestions() async {
        fatalError()
    }
    
    func fetchUserRecordCoount() async {
        // capture
        let mentoryiOS = self.owner!
        let mentoryDB = mentoryiOS.mentoryDB
        
        // process
        let recordCount: Int
        do {
            recordCount = try await mentoryDB.getRecordCount()
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        self.recordCount = recordCount
    }
    
    
    // MARK: DELETE
//    func loadTodayMentorMessageTest() async {
//        let alanLLM = owner!.alanLLM
//        let mentoryDB = owner!.mentoryDB
//        do {
//            let randomCharacter = MentoryCharacter.random
//            let question = AlanQuestion(randomCharacter.question)
//            let NewMessageFromAlanLLM: String?
//            do {
//                //AlanLLM 호출
//                logger.debug("AlanLLM: 멘토메세지 요청합니다.")
//                let response = try await alanLLM.question(question)
//                NewMessageFromAlanLLM = response.content
//                logger.debug("AlanLLM: 멘토메세지 요청성공: \(response.content)")
//            } catch {
//                logger.error("AlanLLM: 멘토메세지 요청실패: \(error.localizedDescription)")
//                return
//            }
//            guard let newMessage = NewMessageFromAlanLLM else {
//                logger.error("AlanLLM: nil을 반환")
//                return
//            }
//            // AlanLLM 호출결과값 DB에 저장
//            try await mentoryDB.saveMentorMessage(newMessage, randomCharacter)
//            
//            //
//            
//            //mutate
//            // DB에 저장된 새 멘토메세지 불러오기
//            if let updatedMessage = try await mentoryDB.fetchMentorMessage() {
//                logger.debug("DB: 멘토메세지 업데이트되었습니다. 메세지: \(updatedMessage.message), 캐릭터: \(updatedMessage.characterType.title)")
//                self.mentorMessage = updatedMessage
//                self.mentorMessageDate = updatedMessage.createdAt
//
//                // Watch로 멘토 메시지 전송
//                WatchConnectivityManager.shared.updateMentorMessage(updatedMessage.message, character: updatedMessage.characterType.rawValue)
//
//                return
//            }
//        } catch {
//            logger.error("loadTodayMentorMessage()처리 실패: \(error.localizedDescription)")
//        }
//    }
//    func loadTodayMentorMessage() async {
//        // capture
//        let alanLLM = owner!.alanLLM
//        let mentoryDB = owner!.mentoryDB
//        do {
//            // DB에서 최신 멘토메세지 가져오기
//            if let lastMessage = try await mentoryDB.fetchMentorMessage(),
//               Calendar.current.isDateInToday(lastMessage.createdAt) {
//                
//                // DB의 멘토메세지가 최신화 되어있을경우 return
//                logger.debug("DB: 멘토메세지가 최신입니다. 메세지: \(lastMessage.message), 캐릭터: \(lastMessage.characterType.title)")
//                self.mentorMessage = lastMessage
//                self.mentorMessageDate = lastMessage.createdAt
//                return
//            }
//            
//            // process
//            // DB의 멘토메세지 nil이거나 최신화 되어있지 않은 경우
//            logger.debug("DB: 멘토메세지가 nil이거나, 최신화되어있지않습니다.")
//            
//            // 새 멘토메세지 받을 캐릭터 랜덤선정
//            let randomCharacter = MentoryCharacter.random
//            let question = AlanQuestion(randomCharacter.question)
//            
//            let NewMessageFromAlanLLM: String?
//            do {
//                //AlanLLM 호출
//                logger.debug("AlanLLM: 멘토메세지 요청합니다.")
//                let response = try await alanLLM.question(question)
//                NewMessageFromAlanLLM = response.content
//                logger.debug("AlanLLM: 멘토메세지 요청성공: \(response.content)")
//            } catch {
//                logger.error("AlanLLM: 멘토메세지 요청실패: \(error.localizedDescription)")
//                return
//            }
//            guard let newMessage = NewMessageFromAlanLLM else {
//                logger.error("AlanLLM: nil을 반환")
//                return
//            }
//            // AlanLLM 호출결과값 DB에 저장
//            try await mentoryDB.saveMentorMessage(newMessage, randomCharacter)
//            
//            //mutate
//            // DB에 저장된 새 멘토메세지 불러오기
//            if let updatedMessage = try await mentoryDB.fetchMentorMessage() {
//                logger.debug("DB: 멘토메세지 업데이트되었습니다. 메세지: \(updatedMessage.message), 캐릭터: \(updatedMessage.characterType.title)")
//                self.mentorMessage = updatedMessage
//                self.mentorMessageDate = updatedMessage.createdAt
//                return
//            }
//        } catch {
//            logger.error("loadTodayMentorMessage()처리 실패: \(error.localizedDescription)")
//        }
//    }

}
