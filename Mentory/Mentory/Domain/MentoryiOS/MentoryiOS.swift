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
    init() {
        
    }
    
    
    // MARK: state
    nonisolated let id: UUID = UUID()
    
    
    // MARK: action
    func setUp() {
        
    }
    
    
    // MARK: value
}
