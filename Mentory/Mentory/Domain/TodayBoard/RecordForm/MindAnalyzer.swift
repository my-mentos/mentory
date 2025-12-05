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
    @Published var suggestions: [SuggestionData] = []
    
    
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
        let mentoryDB = mentoryiOS.mentoryDB
        
        do {
            try await mentoryDB.setCharacter(character)
            logger.debug("MindAnalyzer에서 선택한 캐릭터 \(character.rawValue)를 MentoryDB에 저장 요청했습니다.")
        } catch {
            logger.error("MindAnalyzer에서 setCharacter 실패: \(error)")
        }
        
        let targetDate = recordForm.targetDate

        // 이미지와 음성 입력 가져오기
        let imageInput = recordForm.imageInput
        let voiceInput = recordForm.voiceInput

        // 멀티모달 입력 로깅
        if imageInput != nil {
            logger.debug("이미지 첨부됨 - 감정 분석에 포함")
        }
        if voiceInput != nil {
            logger.debug("음성 첨부됨 - 감정 분석에 포함")
        }


        // process - FirebaseLLM
        // 감정 분석 (텍스트 + 이미지 + 음성)
        let question = FirebaseQuestion(
            textInput,
            imageData: imageInput,
            voiceURL: voiceInput
        )

        let analysis: FirebaseAnalysis
        do {
            analysis = try await firebaseLLM.getEmotionAnalysis(question, character: character)
            logger.debug("멀티모달 감정 분석 완료")
        } catch {
            logger.error("\(error)")
            return
        }
        
        // process - MentoryDB
        // DailyRecord & DailySuggestion 생성
        let suggestionDatas = analysis.actionKeywords
            .map { actionText in
                SuggestionData(content: actionText)
            }
        do {
            let recordData = RecordData(
                id: .init(),
                recordDate: targetDate,
                createdAt: .now,
                analyzedResult: analysis.empathyMessage,
                emotion: analysis.mindType
            )
            
            try await mentoryDB.submitAnalysis(
                recordData: recordData,
                suggestionData: suggestionDatas
            )
            
            logger.debug("MentoryDB에 RecordData와 SuggestionData를 저장했습니다.")
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        self.mindType = analysis.mindType
        self.analyzedResult = analysis.empathyMessage
        self.suggestions = suggestionDatas
        
        let suggestions = analysis.actionKeywords
            .map { keyword in
                Suggestion(
                    owner: todayBoard,
                    target: .random,
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
