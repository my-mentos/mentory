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
    
    nonisolated let character: MentoryCharacter? = nil
    
    @Published private(set) var content: String? = nil
    
    
    
    // MARK: action
    func setRandomCharacter() {
        
    }
    func fetchUserCharacter() async {
        
    }
    
    func updateContent() async {
        let mentoryiOS = self.owner!.owner!
        
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
        self.content = messageContent
    }
    
    
    // MARK: value
}
