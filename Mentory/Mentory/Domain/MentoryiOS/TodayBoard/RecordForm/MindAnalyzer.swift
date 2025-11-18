//
//  MindAnalyzer.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class MindAnalyzer: Sendable, ObservableObject {
    // MARK: core
    init(owner: RecordForm) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    nonisolated let logger = Logger(subsystem: "MentoryiOS.MindAnalyzer", category: "Domain")
    weak var owner: RecordForm?
    
    @Published var isAnalyzing: Bool = false
    @Published var selectedCharacter: CharacterType? = nil
    @Published var mindType: MindType? = nil
    @Published var analyzedResult: String? = nil
    
    
    // MARK: action
    func startAnalyzing() async{
        // capture
        guard let textInput = owner?.textInput else {
            logger.error("TextInput이 비어있습니다.")
            return
        }

        guard textInput.isEmpty == false else {
            logger.error("textInput이 비어있습니다.")
            return
        }
        
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        let alanLLM = mentoryiOS.alanLLM
        
        
        // process
        let answer: AlanLLM.Answer
        do {
            let question = AlanLLM.Question(textInput)
            answer = try await alanLLM.question(question)
            
            
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        self.analyzedResult = answer.content
        self.mindType = .unPleasant
    }
    
    
    // MARK: value
    enum CharacterType: Sendable {
        case A
        case B
    }
    
    enum MindType: Sendable {
        case veryUnpleasant
        case unPleasant
        case slightlyUnpleasant
        case neutral
        case slightlyPleasant
        case pleasant
        case veryPleasant
    }
}
