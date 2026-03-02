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
import MentoryDBAdapter


// MARK: Object
@MainActor
public final class RecordForm: Sendable, ObservableObject, Identifiable {
    // MARK: core
    public init(owner: TodayBoard,
                targetDate: MentoryDate) {
        self.owner = owner
        self.targetDate = targetDate
    }
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard.RecordForm", category: "Domain")


    // MARK: state
    public nonisolated let id = UUID()
    public nonisolated let targetDate: MentoryDate
    public weak var owner: TodayBoard?
    
    @Published public var isDisabled: Bool = true
    
    @Published public var mindAnalyzer: MindAnalyzer? = nil

    @Published public var titleInput: String = ""
    @Published public var textInput: String = ""
    @Published public var imageInput: Data? = nil
    @Published public var voiceInput: URL? = nil
    
    @Published public var canProceed: Bool = false
    
    
    // MARK: action
    public func checkDisability() async {
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
    
    public func validateInput() {
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
    public func submit() async {
        // capture
        guard self.mindAnalyzer == nil else {
            logger.error("이미 MindAnalyzer가 존재합니다.")
            return
        }
        guard self.canProceed == true else {
            logger.error("canProceed가 false입니다. 먼저 validateInput을 실행해주세요.")
            return
        }
        

        // mutate
        self.mindAnalyzer = MindAnalyzer(owner: self)
    }

    public func removeForm() {
        // capture
        let todayBoard = self.owner!
        
        // mutate
        todayBoard.recordForms = []
    }
    
    public func finish() {
        //capture
        let todayBoard = self.owner!
        
        //mutate
        todayBoard.recordFormSelection = nil
    }

    // MARK: value
    public enum RecordCheckResult: Sendable, Hashable {
        case recordAlreadyExist
        case recordNotExist
    }
}
