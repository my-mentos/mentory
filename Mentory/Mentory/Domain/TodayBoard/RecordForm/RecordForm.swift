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
    init(owner: TodayBoard, targetDate: RecordDate) {
        self.owner = owner
        self.targetDate = targetDate
    }
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard.RecordForm", category: "Domain")


    // MARK: state
    nonisolated let id = UUID()
    let targetDate: RecordDate  // 이 폼이 어느 날짜의 일기인지
    weak var owner: TodayBoard?
    
    @Published var mindAnalyzer: MindAnalyzer? = nil

    @Published var titleInput: String = ""
    @Published var textInput: String = ""
    @Published var imageInput: Data? = nil
    @Published var voiceInput: URL? = nil
    
    @Published var canProceed: Bool = false
    
    var startTime: Date? = nil // 기록 시작 시간 (RecordFormView가 열릴 때 설정됨)
    var completionTime: TimeInterval? = nil // 기록 완성까지 걸린 시간
    
    
    // MARK: action
    func validateInput() {
        // capture
        let title = self.titleInput
        let text = self.textInput
    
        //process
        let canProceedResult: Bool = !title.isEmpty && !text.isEmpty
        logger.debug("submit 가능\(canProceedResult)")
        // mutate
        self.canProceed = canProceedResult
    }
    func submit() async {
        // capture
        guard self.canProceed == true else {
            logger.error("canProceed가 false입니다. 먼저 validateInput을 실행해주세요.")
            return
        }

        guard titleInput.isEmpty == false else {
            logger.error("RecordForm의 titleInput에는 값이 존재해야 합니다. 현재 값이 비어있습니다.")
            return
        }
        if titleInput.isEmpty {
            
            return
        } else if textInput.isEmpty && voiceInput == nil && imageInput == nil {
            logger.error("RecordForm의 내용 입력이 비어있습니다. 텍스트, 이미지, 음성 중 하나 이상의 값이 필요합니다.")
            return
        }
        
        guard let todayBoard = owner,
              let mentory = todayBoard.owner,
              let settingBoard = mentory.settingBoard else {
            logger.warning("리마인더 예약에 필요한 owner 체인이 없습니다.")
            return
        }

        
        // process
        if let startTime {
            self.completionTime = Date().timeIntervalSince(startTime)
            logger.info("기록 완성 시간: \(self.completionTime!)초")
        } else {
            logger.warning("startTime이 설정되지 않았습니다.")
        }
        
        let reminderTime = settingBoard.reminderTime
        
        // 기존 알림 전부 삭제
        await mentory.reminderCenter.cancelAllWeeklyReminders()
        
        // 마지막 기록(baseDate) 기준으로 알림 1개만 다시 예약
        await mentory.reminderCenter.scheduleWeeklyReminder(
            baseDate: .now,
            reminderTime: reminderTime
        )
        

        // mutate
        self.mindAnalyzer = MindAnalyzer(owner: self)
    }

    
    func removeForm() {
        // capture
        guard let todayBoard = self.owner else {
            logger.error("RecordForm의 부모인 TodayBoard가 존재하지 않습니다.")
            return
        }
        
        // mutate
        todayBoard.recordForm = nil
    }
    

    // MARK: value
}
