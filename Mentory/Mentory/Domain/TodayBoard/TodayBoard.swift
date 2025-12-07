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
    func areAllRecordFormsDisabled() -> Bool {
        return self.recordForms.allSatisfy(\.isDisabled)
    }
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
        let totalCount = self.suggestions
            .count
        
        let doneCount = self.suggestions
            .filter { $0.isDone == true }
            .count
        
        return "\(doneCount)/\(totalCount)"
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
            logger.error("이미 recordForms 배열 안에 객체들이 존재합니다.\(self.recordForms.count)")
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
        logger.debug("recordForms 배열이 생성되었습니다.\(recordForms)")
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

        // Watch로 전송
        await sendSuggestionsToWatch()
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


    // MARK: - Watch Connectivity
    func sendSuggestionsToWatch() async {
        let todos = suggestions.map { $0.content }
        let completionStatus = suggestions.map { $0.isDone }

        await WatchConnectivityManager.shared.updateActionTodos(todos, completionStatus: completionStatus)
        logger.debug("Suggestions를 Watch로 전송: \(todos.count)개")
    }

    func handleWatchTodoCompletion(todoText: String, isCompleted: Bool) async {
        // todoText로 해당 Suggestion 찾기
        guard let suggestion = suggestions.first(where: { $0.content == todoText }) else {
            logger.error("Watch로부터 받은 투두를 찾을 수 없음: \(todoText)")
            return
        }

        // UI 상태 업데이트
        suggestion.isDone = isCompleted
        logger.debug("Watch로부터 투두 완료 상태 업데이트: \(todoText) = \(isCompleted)")

        // TODO: MentoryDB에 저장하는 로직 구현 필요
        // let mentoryiOS = owner!
        // let mentoryDB = mentoryiOS.mentoryDB
        // try await mentoryDB.updateSuggestionCompletion(...)
    }
}
