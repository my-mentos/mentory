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
import FirebaseLLMAdapter
import MentoryDBAdapter


// MARK: Object
@MainActor
final class MindAnalyzer: Sendable, ObservableObject, Distinguishable {
    // MARK: core
    nonisolated let logger = Logger()
    init(owner: RecordForm) {
        self.owner = owner
    }
    
    
    // MARK: state
    public nonisolated let id = UUID()
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
    
    private(set) var currentDate: MentoryDate = .now
    func refreshCurrentDate() {
        self.currentDate = .now
    }
    
    
    
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
        
        guard let analysis = await firebaseLLM.getEmotionAnalysis(question, character: character) else {
            logger.error("FirebaseLLM 감정 분석 과정에서 오류가 발생했습니다.")
            return
        }
        logger.debug("멀티모달 감정 분석 완료")
        
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
        self.isAnalyzeFinished = true
    }
    
    func updateSuggestions() async {
        // capture
        let currentDate = self.currentDate
        
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        let mentoryDB = mentoryiOS.mentoryDB
        
        // process - MentoryDB
        let recentRecord: (any DailyRecordInterface)?
        do {
            recentRecord = try await mentoryDB.getRecentRecord()
            logger.debug("최근일기가져오기")
        } catch {
            logger.error("\(#function) 실패: \(error)")
            return
        }
        
        guard let recentRecord else {
            logger.error("MentoryDB 안에 최근 Record가 존재하지 않습니다.")
            return
        }
        
        // process - MentoryDB
        let suggestionDatas: [SuggestionData]
        do {
            suggestionDatas = try await recentRecord.getSuggestions()
        } catch {
            logger.error("\(#function) 실패 : \(error)")
            return
        }
        
        // mutate
        todayBoard.suggestions = suggestionDatas
            .map { Suggestion(
                owner: todayBoard,
                target: $0.target,
                content: $0.content,
                isDone: $0.isDone)
            }
        todayBoard.recentSuggestionUpdate = currentDate
        logger.debug("추천행동가져오기\(suggestionDatas)")
        
        // 1. getRecentRecordData() -> recordAt: MentoryDate
        // recordAt vs owner!.recordAt -> 더 최신이라면 업데이트한다
        
    }
    
    func cancel() {
        // capture
        let recordForm = self.owner!
        
        // mutate
        recordForm.mindAnalyzer = nil
    }
    
    func finish() {
        //capture
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        
        //mutate
        todayBoard.recordFormSelection = nil
//        todayBoard.recordForms.removeAll { recordForm in
//            logger.debug("remove: 전체 \(recordForm.id)/ \(self.owner!.id)")
//            return recordForm.id == self.owner!.id
//        }
        
    }
}
