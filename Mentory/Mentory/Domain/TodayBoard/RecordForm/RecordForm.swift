//
//  RecordForm.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
//
import Foundation
import Combine
import OSLog
import Values


// MARK: Object
@MainActor
final class RecordForm: Sendable, ObservableObject, Identifiable {
    // MARK: core
    init(owner: TodayBoard,
         targetDate: MentoryDate) {
        self.owner = owner
        self.targetDate = targetDate
    }
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard.RecordForm", category: "Domain")


    // MARK: state
    nonisolated let id = UUID()
    nonisolated let targetDate: MentoryDate
    weak var owner: TodayBoard?
    
    @Published var isDisabled: Bool = true
    
    @Published var mindAnalyzer: MindAnalyzer? = nil

    @Published var titleInput: String = ""
    @Published var textInput: String = ""
    @Published var imageInput: Data? = nil
    @Published var voiceInput: URL? = nil
    
    @Published var canProceed: Bool = false
    
    
    // MARK: action
    func checkDisability() async {
        // capture
        let recordDate = self.targetDate
        logger.debug("targetDate: \(recordDate.rawValue)")
        let todayBoard = self.owner!
        let mentoryiOS = todayBoard.owner!
        
        let mentoryDB = mentoryiOS.mentoryDB
        
        // process
        let isRecordAlreadyExist: RecordCheckResult
        do {
            switch try await mentoryDB.isSameDayRecordExist(for: recordDate) {
            case true:
                isRecordAlreadyExist = .recordAlreadyExist
            case false:
                isRecordAlreadyExist = .recordNotExist
            }
        } catch {
            logger.error("\(#function) 실패: \(error)")
            return
        }
        
        // mutate
        switch isRecordAlreadyExist {
        case .recordAlreadyExist:
            self.isDisabled = true
        case .recordNotExist:
            self.isDisabled = false
        }
        logger.debug("isDisabled: \(self.isDisabled)")
    }
    
    func validateInput() {
        // capture
        let title = self.titleInput
        let text = self.textInput
    
        //process
        let isTitleNotEmpty = !title.isEmpty
        let isTextNotEmpty = !text.isEmpty
        
        let canUserProceed = isTitleNotEmpty && isTextNotEmpty
        
        // mutate
        self.canProceed = canUserProceed
    }
    func submit() async {
        // capture
        guard self.mindAnalyzer == nil else {
            logger.error("이미 MindAnalyzer가 존재합니다.")
            return
        }
        guard self.canProceed == true else {
            logger.error("canProceed가 false입니다. 먼저 validateInput을 실행해주세요.")
            return
        }
        
//        let mentoryiOS = todayBoard.owner!

        // 이를 어디에서 설명해야 하는가.
//        let settingBoard = mentoryiOS.settingBoard!

        
//        // process
//        let reminderTime = settingBoard.reminderTime
//        
//        // 기존 알림 전부 삭제
//        await mentory.reminderCenter.cancelAllWeeklyReminders()
//        
//        // 마지막 기록(baseDate) 기준으로 알림 1개만 다시 예약
//        await mentory.reminderCenter.scheduleWeeklyReminder(
//            baseDate: .now,
//            reminderTime: reminderTime
//        )
        

        // mutate
        self.mindAnalyzer = MindAnalyzer(owner: self)
    }

    func removeForm() {
        // capture
        let todayBoard = self.owner!
        
        // mutate
        todayBoard.recordForms = []
    }
    
    func finish() {
        //capture
        let todayBoard = self.owner!
        
        //mutate
        todayBoard.recordFormSelection = nil
    }

    // MARK: value
    enum RecordCheckResult: Sendable, Hashable {
        case recordAlreadyExist
        case recordNotExist
    }
}
