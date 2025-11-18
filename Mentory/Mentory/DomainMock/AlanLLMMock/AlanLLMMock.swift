//
//  AlanLLMMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation


// MARK: Mock
nonisolated
struct AlanLLMMock: AlanLLMInterface {
    // MARK: flow
    @concurrent
    func question(_ question: AlanLLM.Question) async throws -> AlanLLM.Answer {
        return await MainActor.run {
            let alanLLMModel = AlanLLMModel.shared
            
            alanLLMModel.questionQueue.append(question)
            alanLLMModel.processQuestions()
            
            let myAnswer = alanLLMModel.answerBox[question.id]!
            
            return myAnswer
        }
    }
    
    @concurrent
    func resetState(token: AlanLLM.AuthToken) async {
        fatalError()
    }
}
