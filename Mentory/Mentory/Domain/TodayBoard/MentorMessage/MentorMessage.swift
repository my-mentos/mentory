//
//  MentorMessage.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import Combine
import Values
import OSLog


// MARK: Object
@MainActor
final class MentorMessage: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger(subsystem: "MentorMessage", category: "Domain")
    init(owner: TodayBoard) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: TodayBoard?
    
    @Published var character: MentoryCharacter? = nil
    
    var recentUpdate: MentoryDate? = nil
    @Published var content: String? = nil
    
    func resetContent() {
        self.content = nil
    }
    
    
    // MARK: action
//    func fetchCharacter() async {
//        // capture
//        guard self.character == nil else {
//            logger.error("이미 Character가 설정되어 있습니다.")
//            return
//        }
//        
//        let todayBoard = self.owner!
//        let mentoryiOS = todayBoard.owner!
//        let mentoryDB = mentoryiOS.mentoryDB
//        
//        
//        // process
//        let character: MentoryCharacter
//        do {
//            let fetchResult = try await mentoryDB.getCharacter()
//            character = fetchResult ?? .random
//        } catch {
//            logger.error("\(#function) 실패 : \(error)")
//            return
//        }
//        
//        
//        // mutate
//        self.character = character
//    }
    
    func updateContent() async {
        // capture
//        guard let character else {
//            logger.error("MentorMessage의 Character가 nil입니다. 먼저 Character를 설정하세요.")
//            return
//        }
        
        if let recentUpdate,
           recentUpdate.isSameDate(as: .now) == true {
            logger.error("\(Date.now) 날짜의 MentorMessage가 이미 존재합니다.")
            return
        }
        
        let character: MentoryCharacter = .random
        
        let mentoryiOS = self.owner!.owner!
        let mentoryDB = mentoryiOS.mentoryDB
        let alanLLM = mentoryiOS.alanLLM
        
        // process
        let messageFromDB: MessageData?
        do {
            messageFromDB = try await mentoryDB.getMentorMessage()
        } catch {
            logger.error("MentoryDB에서 MentorMessage 가져오기 실패: \(error)")
            return
        }
        
        let messageContent: String
        let messageCharacter: MentoryCharacter
        do {
            let isMessageValid = messageFromDB?.createdAt
                .isSameDate(as: .now)
                
            if isMessageValid == true {
                // Message가 유효한 경우
                messageContent = messageFromDB!.content
                messageCharacter = messageFromDB!.characterType
            } else {
                // AlanLLM - 새로운 메시지 가져오기
                let question = AlanQuestion(character.question)
                
                async let answer = try await alanLLM.question(question)
                let newMessageContent = try await answer.content
                
                messageContent = newMessageContent
                messageCharacter = character
                
                
                // MentoryDB - 새로운 메시지 저장
                let newMessage = MessageData(
                    createdAt: .now,
                    content: messageContent,
                    characterType: character)
                
                try await mentoryDB.setMentorMessage(newMessage)
            }
        } catch {
            logger.error("setUpMentorMessage 에러 발생 : \(error)")
            return
        }
        
        // mutate
        self.content = messageContent
        self.character = messageCharacter
        self.recentUpdate = .now
    }
    
    
    // MARK: value
}
