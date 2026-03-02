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
public final class Onboarding: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.Onboarding", category: "Domain")
    
    public init(owner: Mentory) {
        self.owner = owner
    }
    
    
    // MARK: state
    public nonisolated let id = UUID()
    public weak var owner: Mentory?
    
    
    @Published public var nameInput: String = ""
    public func setName(_ newName: String) {
        self.nameInput = newName
    }
    
    @Published public var validationResult: ValidationResult = .none
    @Published public private(set) var isUsed: Bool = false
    
    
    // MARK: action
    public func validateInput() {
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
    public func next() {
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
        
        mentoryiOS.todayBoard = TodayBoard(owner: mentoryiOS)
        mentoryiOS.settingBoard = SettingBoard(owner: mentoryiOS)
        mentoryiOS.statBoard = StatBoard(owner: mentoryiOS)

        self.isUsed = true
    }
    
    
    // MARK: value
    public nonisolated enum ValidationResult: String, Sendable, Hashable {
        case none
        case nameInputIsEmpty
    }
}
