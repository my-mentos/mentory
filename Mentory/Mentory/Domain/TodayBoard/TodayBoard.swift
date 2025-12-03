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
    private var stdDate: MentoryDate = .now
    internal func updateStdDate() {
        self.stdDate = .now
    }
    
    @Published var recordCount: Int? = nil
    
    @Published var suggestions: [Suggestion] = []
    
    
    // MARK: action
    func setUpMentorMessage() async {
        // capture
        guard self.mentorMessage == nil else {
            logger.error("이미 MentorMessage 객체가 존재합니다.")
            return
        }
        
        // mutate
        self.mentorMessage = MentorMessage(owner: self)
    }
    
    func setUpRecordForms() async {
        // capture
        guard self.recordForms.isEmpty == true else {
            logger.error("이미 recordForms 배열 안에 객체들이 존재합니다.")
            return
        }
        let now = self.stdDate

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
        
        // process
        
        // mutate
        fatalError("updateStdDate로 바뀐 기준값이 하루를 넘겼을 때 RecordForm 객체를 업데이트하는 코드가 필요합니다.")
    }
    
    func setUpSuggestions() async {
        // capture
        
        // process
        
        // mutate
        fatalError()
    }
    
    func fetchUserRecordCoount() async {
        // capture
        let mentoryiOS = self.owner!
        let mentoryDB = mentoryiOS.mentoryDB
        
        // process
        let recordCount: Int
        do {
            recordCount = try await mentoryDB.getRecordCount()
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        self.recordCount = recordCount
    }
}
