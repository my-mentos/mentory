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
        
        
        // mutate
        self.mindType = analysis.mindType
        self.analyzedResult = analysis.empathyMessage
        todayBoard.actionKeyWordItems = analysis.actionKeywords.map {($0,false)}
        logger.debug("추천행동: \(todayBoard.actionKeyWordItems)")
        self.isAnalyzeFinished = true
    }
    
    // TODO: saveRecord를 analyze 액션으로 통합,
    // saveRecord() ->
    func saveRecord() async {
        // capture
        guard let analyzedContent = self.analyzedResult,
              !analyzedContent.isEmpty else {
            logger.error("분석된 내용이 비어있습니다. 저장을 중단합니다.")
            return
        }
        
        
        // capture
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        
        let mentoryDB = mentoryiOS.mentoryDB
        
        let actionTexts = todayBoard.actionKeyWordItems.map { $0.0 }
        let actionCompletionStatus = todayBoard.actionKeyWordItems.map { $0.1 }
        
        
        // MentoryRecord 생성
        let recordData = RecordData(
            id: UUID(),
            recordDate: recordForm.targetDate.toDate(),  // 일기가 속한 날짜
            createdAt: Date(),  // 실제 작성 시간
            
            content: "", // content가 무엇인가.
            analyzedResult: analyzedContent,
            emotion: self.mindType!,
            
            actionTexts: actionTexts,
            actionCompletionStatus: actionCompletionStatus
        )
        
        
        // process
        do {
            try await mentoryDB.saveRecord(recordData)
            
            logger.info("레코드 저장 성공: \(recordData.id)")
            logger.debug("레코드 저장추천행동\(recordData.actionTexts))")
            
            // 저장된 레코드 ID를 TodayBoard에 저장 (체크 상태 업데이트용)
            todayBoard.latestRecordId = recordData.id
        } catch {
            logger.error("레코드 저장 실패: \(error)")
        }
    }
    
    func cancel() {
        // capture
        let recordForm = self.owner
        
        // mutate
        recordForm?.mindAnalyzer = nil
    }
}
