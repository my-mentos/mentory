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
    // MARK: core
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

    public var emoji: String {
        switch self {
        case .veryUnpleasant: return "😣"
        case .unPleasant: return "😕"
        case .slightlyUnpleasant: return "🙁"
        case .neutral: return "😐"
        case .slightlyPleasant: return "🙂"
        case .pleasant: return "😄"
        case .veryPleasant: return "🤩"
        }
    }
}
