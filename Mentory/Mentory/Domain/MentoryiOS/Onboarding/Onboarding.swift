//
//  Onboarding.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
final class Onboarding: Sendable, ObservableObject {
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let owner: MentoryiOS
    
    
    // MARK: action
    
    
    // MARK: value
}
