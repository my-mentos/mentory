//
//  TodayBoard.swift
//  Mentory
//
//  Created by SJS, 구현모 on 11/14/25.
//
import Foundation
import Combine
import Values
import OSLog


// MARK: Object
@MainActor
final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryiOS?
    
    @Published var mentorMessage: MentorMessage? = nil

    @Published var recordForms: [RecordForm] = []
    @Published var recordFormSelection: RecordForm? = nil
    func recentUpdatedate() -> MentoryDate? {
        guard self.recordForms.isEmpty == false else {
            return nil
        }
        
        return self.recordForms
            .map { $0.targetDate }
            .max()!
    }
    
    
    private(set) var currentDate: MentoryDate = .now
    func setCurrentDate(_ newDate: MentoryDate) {
        guard newDate > currentDate else {
            logger.error("이전 날짜로 설정하려고 했습니다.")
            return
        }
        
        self.currentDate = newDate
    }
    func refreshCurrentDate() {
        self.currentDate = .now
    }
    
    @Published var recordCount: Int? = nil
    
    @Published var suggestions: [Suggestion] = []
    var recentSuggestionUpdate: MentoryDate? = nil
    func getSuggestionIndicator() -> String {
        "2/3"
    }
    
    
    // MARK: action
    func setUpMentorMessage() async {
        // capture
        guard self.mentorMessage == nil else {
            logger.error("이미 MentorMessage 객체가 존재합니다.")
            return
        }
        
        // mutate
        let mentorMessage = MentorMessage(owner: self)
        self.mentorMessage = mentorMessage
        logger.debug("mentorMessage 객체가 생성되었습니다.")
    }
    
    func setUpRecordForms() async {
        // capture
        guard self.recordForms.isEmpty == true else {
            logger.error("이미 recordForms 배열 안에 객체들이 존재합니다.")
            return
        }
        let now = MentoryDate.now

        // process
        let today = now
        let yesterday = today.dayBefore()
        let twoDaysAgo = today.twoDaysBefore()
        
        let dates = [today, yesterday, twoDaysAgo]

        
        // mutate
        let recordForms = dates.map { date in
            RecordForm(owner: self, targetDate: date)
        }
        self.recordForms = recordForms
    }
    func updateRecordForms() async {
        // capture
        let currentDate = self.currentDate
        let recordForms = self.recordForms
        guard recordForms.isEmpty == false else {
            logger.error("recordForms가 비어 있어 updateRecordForms을 취소합니다.")
            return
        }
        guard let recentUpdatedate = self.recentUpdatedate() else {
            logger.error("recentUpdateDate가 nil이어서 updateRecordForms을 취소합니다.")
            return
        }
        
        // process
        let isSameDay = recentUpdatedate.isSameDate(as: currentDate)
        guard isSameDay == false else {
            logger.error("현재 날짜와 가장 최근 업데이트된 날짜가 같습니다. 아무것도 하지 않습니다.")
            return
        }
        
        let targetDates: [MentoryDate] = [
            currentDate,
            currentDate.dayBefore(),
            currentDate.twoDaysBefore()
        ]
        
        var newRecordForms: [RecordForm] = []
        for targetDate in targetDates {
            if let existing = recordForms.first(where: { $0.targetDate.isSameDate(as: targetDate) }) {
                    newRecordForms.append(existing)
            } else {
                let newForm = RecordForm(owner: self, targetDate: targetDate)
                newRecordForms.append(newForm)
            }
        }
        newRecordForms.sort { $0.targetDate < $1.targetDate }
            
        // mutate
        self.recordForms = newRecordForms
    }
    
    func loadSuggestions() async {
        // capture
        let currentDate = self.currentDate
        
        let mentoryiOS = self.owner!
        let mentoryDB = mentoryiOS.mentoryDB
        
        // process - MentoryDB
        let recentRecord: (any DailyRecordInterface)?
        do {
            recentRecord = try await mentoryDB.getRecentRecord()
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
        self.suggestions = suggestionDatas
            .map { Suggestion(
                owner: self,
                target: $0.target,
                content: $0.content,
                isDone: $0.isDone)
            }
        self.recentSuggestionUpdate = currentDate
    }
    
    func fetchUserRecordCoount() async {
        // capture
        let mentoryiOS = self.owner!
        let mentoryDB = mentoryiOS.mentoryDB
        
        // process
        let recordCount: Int
        do {
            async let count = try await mentoryDB.getRecordCount()
            recordCount = try await count
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        self.recordCount = recordCount
    }

    
    // TODO: etc
    func handleWatchTodoCompletion(todoText: String, isCompleted: Bool) async {
        // capture
//        guard let recordId = latestRecordId else {
//            logger.error("업데이트할 레코드 ID가 없습니다.")
//            return
//        }
//
//        // 투두 텍스트로 인덱스 찾기
//        guard let index = actionKeyWordItems.firstIndex(where: { $0.0 == todoText }) else {
//            logger.error("투두를 찾을 수 없음: \(todoText)")
//            return
//        }
//
//        // process
//        // UI 상태 업데이트
//        actionKeyWordItems[index].1 = isCompleted
//        logger.debug("Watch로부터 투두 완료 상태 업데이트: \(todoText) = \(isCompleted)")
//
//        // records 배열에서도 업데이트 (인디케이터 반영용, 로직 개선 필요)
//        if let recordIndex = records.firstIndex(where: { $0.id == recordId }) {
//            let oldRecord = records[recordIndex]
//            var newCompletionStatus = oldRecord.actionCompletionStatus
//            newCompletionStatus[index] = isCompleted
//
//            let updatedRecord = RecordData(
//                id: oldRecord.id,
//                recordDate: oldRecord.recordDate,
//                createdAt: oldRecord.createdAt,
//                content: oldRecord.content,
//                analyzedResult: oldRecord.analyzedResult,
//                emotion: oldRecord.emotion,
//                actionTexts: oldRecord.actionTexts,
//                actionCompletionStatus: newCompletionStatus
//            )
//            records[recordIndex] = updatedRecord
//            logger.debug("records 배열 업데이트 완료 - 인디케이터가 반영됩니다.")
//        }
//
//        // DB 업데이트
//        let mentoryDB = owner!.mentoryDB
//        let completionStatus = actionKeyWordItems.map { $0.1 }
//
//        do {
//            try await mentoryDB.updateActionCompletion(recordId: recordId, completionStatus: completionStatus)
//            logger.debug("Watch 투두 완료 상태가 DB에 저장되었습니다.")
//        } catch {
//            logger.error("Watch 투두 완료 상태 DB 저장 실패: \(error)")
//        }
    }
}
