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
import MentoryDBAdapter
import WatchManager


// MARK: Object
@MainActor
public final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")
    public init(owner: Mentory) {
        self.owner = owner
    }
    
    
    // MARK: state
    public nonisolated let id = UUID()
    public weak var owner: Mentory?
    
    @Published public var mentorMessage: MentorMessage? = nil

    @Published public var recordForms: [RecordForm] = []
    public func areAllRecordFormsDisabled() -> Bool {
        return self.recordForms.allSatisfy(\.isDisabled)
    }
    @Published public var recordFormSelection: RecordForm? = nil
    public func recentUpdatedate() -> MentoryDate? {
        guard self.recordForms.isEmpty == false else {
            return nil
        }
        
        return self.recordForms
            .map { $0.targetDate }
            .max()!
    }
    
    
    public private(set) var currentDate: MentoryDate = .now
    public func setCurrentDate(_ newDate: MentoryDate) {
        guard newDate > currentDate else {
            logger.error("이전 날짜로 설정하려고 했습니다.")
            return
        }
        
        self.currentDate = newDate
    }
    public func refreshCurrentDate() {
        self.currentDate = .now
    }
    
    @Published public var recordCount: Int? = nil
    
    @Published public var suggestions: [Suggestion] = []
    public var recentSuggestionUpdate: MentoryDate? = nil
    public func getSuggestionIndicator() -> String {
        let totalCount = self.suggestions
            .count
        
        let doneCount = self.suggestions
            .filter { $0.isDone == true }
            .count
        
        return "\(doneCount)/\(totalCount)"
    }
    public var suggestionProgress: Double {
        guard suggestions.count > 0 else { return 0 }
        return Double(suggestions.filter { $0.isDone }.count) / Double(suggestions.count)
    }
    @Published public var completedSuggestionsCount: Int = 0
    @Published public var earnedBadges: [BadgeType] = []
    
    
    // MARK: action
    public func setUpMentorMessage() async {
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
    
    public func setUpRecordForms() async {
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
    public func updateRecordForms() async {
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
    
    public func loadSuggestions() async {
        // capture
        let currentDate = self.currentDate
        
        let mentoryiOS = self.owner!
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
        self.suggestions = suggestionDatas
            .map { Suggestion(
                owner: self,
                target: $0.target,
                content: $0.content,
                isDone: $0.isDone)
            }
        self.recentSuggestionUpdate = currentDate
        logger.debug("추천행동가져오기\(suggestionDatas)")
    }
    
    public func fetchUserRecordCoount() async {
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

    public func fetchEarnedBadges() async {
        // capture
        let mentoryiOS = self.owner!
        let mentoryDB = mentoryiOS.mentoryDB

        // process
        let completedCount: Int
        do {
            async let count = try await mentoryDB.getCompletedSuggestionsCount()
            completedCount = try await count
        } catch {
            logger.error("완료된 제안 개수 조회 실패: \(error)")
            return
        }

        // mutate
        self.completedSuggestionsCount = completedCount
        self.earnedBadges = BadgeType.earnedBadges(completedCount: completedCount)
        logger.debug("완료된 제안: \(completedCount)개, 획득한 뱃지: \(self.earnedBadges.count)개")
    }


    // MARK: - Watch Connectivity
    public func sendSuggestionsToWatch() async {
        let todos = suggestions.map { $0.content }
        let completionStatus = suggestions.map { $0.isDone }
        let mentoryiOS = self.owner!
        
        await mentoryiOS.watchConnectivity?.updateContext(
            message: mentorMessage?.content,
            character: mentorMessage?.character?.rawValue,
            todos: todos,
            todoCompletions: completionStatus
        )
        
        logger.debug("Suggestions를 Watch로 전송: \(todos.count)개")
    }

    public func handleWatchTodoCompletion(todoText: String, isCompleted: Bool) async {
        // todoText로 해당 Suggestion 찾기
        guard let suggestion = suggestions.first(where: { $0.content == todoText }) else {
            logger.error("Watch로부터 받은 투두를 찾을 수 없음: \(todoText)")
            return
        }

        // UI 상태 업데이트
        suggestion.isDone = isCompleted
        logger.debug("Watch로부터 투두 완료 상태 업데이트: \(todoText) = \(isCompleted)")

        // MentoryDB에 저장
        let mentoryiOS = owner!
        let mentoryDB = mentoryiOS.mentoryDB
        let targetId = suggestion.target.rawValue

        do {
            try await mentoryDB.updateSuggestionStatus(targetId: targetId, isDone: isCompleted)
            logger.debug("Watch 투두 완료 상태 DB 저장 완료: \(todoText)")
        } catch {
            logger.error("Watch 투두 완료 상태 DB 저장 실패: \(error)")
        }
    }
}
