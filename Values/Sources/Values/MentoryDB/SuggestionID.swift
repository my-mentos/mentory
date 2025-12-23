//
//  SuggestionID.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation


// MARK: Value
nonisolated
public struct SuggestionID: Sendable, Hashable, Codable {
    // MARK: core
    public let rawValue: UUID
    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }
    
    public static var random: SuggestionID {
        self.init(UUID())
    }
}
