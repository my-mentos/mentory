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
    nonisolated private let id = UUID()
    nonisolated let owner: MentoryiOS
    nonisolated private let logger = Logger(subsystem: "Mentory", category: "Domain")
    
    @Published var nameInput: String = ""
    func setName(_ newName: String) {
        self.nameInput = newName
    }
    
    @Published var validationResult: ValidationResult = .none
    
    
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
        let mentoryiOS = self.owner
        let nameInput = self.nameInput
        
        // mutate
        mentoryiOS.onboardingFinished = true
        mentoryiOS.userName = nameInput
        mentoryiOS.onboarding = nil
    }
    
    
    // MARK: value
    nonisolated enum ValidationResult: String, Sendable, Hashable {
        case none
        case nameInputIsEmpty
    }
}
