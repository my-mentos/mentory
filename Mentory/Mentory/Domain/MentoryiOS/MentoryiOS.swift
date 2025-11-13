//
//  MentoryiOS.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class MentoryiOS: Sendable, ObservableObject {
    // MARK: core
    init() { }
    
    
    // MARK: state
    nonisolated let id: UUID = UUID()
    nonisolated let logger = Logger(subsystem: "Mentory", category: "MentoryiOS")
    
    @Published var userName: String? = nil
    @Published var onboardingFinished: Bool = false
    @Published var onboarding: Onboarding? = nil
    
    
    // MARK: action
    func setUp() {
        // capture
        guard onboarding == nil else {
            logger.error("Onboarding 객체가 이미 존재합니다.")
            return
        }
        
        // mutate
        self.onboarding = Onboarding(owner: self)
    }
    
    
    // MARK: value
}
