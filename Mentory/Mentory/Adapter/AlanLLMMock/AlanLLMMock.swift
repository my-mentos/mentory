//
//  AlanLLMMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation
import Values


// MARK: Mock
nonisolated
struct AlanLLMMock: AlanLLMInterface {
    // MARK: core
    nonisolated let model = AlanLLMModel()
    
    
    // MARK: flow
    @concurrent
    func question(_ question: AlanQuestion) async throws -> AlanLLM.Answer {
        return await MainActor.run {
            let alanLLM = model
            
            alanLLM.questionQueue.append(question)
            alanLLM.processQuestions()
            
            let myAnswer = alanLLM.answerBox[question.id]!
            
            return myAnswer
        }
    }
}
