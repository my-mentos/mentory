//
//  MindAnalyzer.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//
import Foundation
import Values
import Combine
import OSLog
import FirebaseAILogic


// MARK: Object
@MainActor
final class MindAnalyzer: Sendable, ObservableObject {
    // MARK: core
    nonisolated let logger = Logger(subsystem: "MentoryiOS.MindAnalyzer", category: "Domain")
    init(owner: RecordForm) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: RecordForm?
    
    @Published private(set) var isAnalyzing: Bool = false
    func startAnalyze() {
        isAnalyzing = true
    }
    func stopAnalyze() {
        isAnalyzing = false
    }
    
    @Published var character: MentoryCharacter? = nil
    
    @Published var isAnalyzeFinished: Bool = false
    @Published var analyzedResult: String? = nil
    @Published var mindType: Emotion? = nil
    
    
    // MARK: action
    func analyze() async {
        // capture
        guard let textInput = owner?.textInput else {
            logger.error("Owner?.textInput이 nil입니다.")
            return
        }
        
        guard textInput.isEmpty == false else {
            logger.error("textInput이 비어 있습니다.")
            return
        }
        
        guard let character else {
            logger.error("MindAnalyzer.character를 먼저 선택해야 합니다.")
            return
        }
        
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        
        let firebaseLLM = mentoryiOS.firebaseLLM
        
        
        // process
        let question = FirebaseQuestion(textInput)
        
        let analysis: FirebaseAnalysis
        do {
            analysis = try await firebaseLLM.getEmotionAnalysis(question, character: character)
        } catch {
            logger.error("\(error)")
            return
        }
        
        // saveRecord를 구현해야 함.
        
        // mutate
        self.mindType = analysis.mindType
        self.analyzedResult = analysis.empathyMessage
        
        let suggestions = analysis.actionKeywords
            .map { keyword in
                Suggestion(
                    owner: todayBoard,
                    source: .random,
                    content: keyword,
                    isDone: false)
            }
        todayBoard.suggestions = suggestions
        
        self.isAnalyzeFinished = true
    }
    
    func cancel() {
        // capture
        let recordForm = self.owner
        
        // mutate
        recordForm?.mindAnalyzer = nil
    }
}
