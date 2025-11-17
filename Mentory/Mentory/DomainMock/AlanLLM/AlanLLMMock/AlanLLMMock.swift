//
//  AlanLLMMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation
import Collections
import OSLog


// MARK: Mock
@MainActor
final class AlanLLMMock: Sendable {
    // MARK: core
    init() { }
    
    
    // MARK: state
    nonisolated let logger = Logger(subsystem: "AlanLLM.AlanLLMMock", category: "Domain")
    nonisolated let answers: [AlanLLM.Answer] = [
        .init(action: .init(name: "speak", speak: "Hello"), content: "Hello"),
        .init(action: .init(name: "speak", speak: "World"), content: "World"),
        .init(action: .init(name: "speak", speak: "Swift"), content: "Swift"),
        .init(action: .init(name: "speak", speak: "Great"), content: "Great"),
        .init(action: .init(name: "speak", speak: "Is it fun?"), content: "Is it fun?"),
        .init(action: .init(name: "speak", speak: "No, it's not fun."), content: "No, it's not fun.")
    ]
    var answerBox: [AlanLLM.Question.ID: AlanLLM.Answer] = [:]
    var questionQueue: Deque<AlanLLM.Question> = []
    
    
    // MARK: action
    func processQuestions() {
        // capture
        guard questionQueue.isEmpty == false else {
            logger.error("questionQueue가 비어 있습니다.")
            return
        }
        
        // mutate
        while questionQueue.isEmpty == false {
            let question = questionQueue.removeFirst()
            
            let randomAnswer = answers.randomElement()!
            
            answerBox[question.id] = randomAnswer
        }
    }
    
    
    // MARK: value

}
