//
//  AlanLLMMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation


// MARK: Mock
nonisolated
struct AlanLLMMock: AlanLLMFlow {
    
    // MARK: flow
    func question(token: AlanLLM.AuthToken, question: AlanLLM.Question) async -> AlanLLM.Answer {
        fatalError()
    }
    
    func resetState(token: AlanLLM.AuthToken) async {
        fatalError()
    }
}
