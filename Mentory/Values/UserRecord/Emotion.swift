//
//  Emotion.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import Foundation


// MARK: Value
@frozen
nonisolated public enum Emotion: String, Codable, Sendable, CaseIterable {
    case veryUnpleasant
    case unPleasant
    case slightlyUnpleasant
    case neutral
    case slightlyPleasant
    case pleasant
    case veryPleasant
    
    
    // MARK: operator
    public static func getAllEmotions() -> [String] {
        return Self.allCases.map { $0.rawValue }
    }
}
