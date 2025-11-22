//
//  Onboarding.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class Onboarding: Sendable, ObservableObject {
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryiOS?
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.Onboarding", category: "Domain")
    
    
    @Published var nameInput: String = ""
    func setName(_ newName: String) {
        self.nameInput = newName
    }
    
    @Published var validationResult: ValidationResult = .none
    @Published private(set) var isUsed: Bool = false
    
    
    // MARK: action
    func validateInput() {
        // capture
        let currentInput = self.nameInput
        
        // mutate
        if currentInput.isEmpty {
            self.validationResult = .nameInputIsEmpty
            return
        } else {
            self.validationResult = .none
            return
        }
    }
    func next() {
        // capture
        guard nameInput.isEmpty == false else {
            logger.error("Onboarding의 nameInput에는 값이 존재해야 합니다. 현재 값이 비어있습니다.")
            return
        }
        guard isUsed == false else {
            logger.error("이미 Onboarding이 사용된 상태입니다.")
            return
        }
        let mentoryiOS = self.owner!
        let nameInput = self.nameInput
        
        
        // mutate
        mentoryiOS.onboardingFinished = true
        mentoryiOS.userName = nameInput

        mentoryiOS.onboarding = nil

        let todayBoard = TodayBoard(owner: mentoryiOS, recordRepository: mentoryiOS.recordRepository)
        mentoryiOS.todayBoard = todayBoard
        todayBoard.recordForm = RecordForm(owner: todayBoard)

        mentoryiOS.settingBoard = SettingBoard(owner: mentoryiOS)

        self.isUsed = true
    }
    
    
    // MARK: value
    nonisolated enum ValidationResult: String, Sendable, Hashable {
        case none
        case nameInputIsEmpty
    }
}
