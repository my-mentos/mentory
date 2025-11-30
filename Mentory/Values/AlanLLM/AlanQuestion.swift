//
//  AlanQuestion.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation


// MARK: Value
nonisolated
public struct AlanQuestion: Sendable, Hashable, Identifiable {
    // MARK: core
    public let id: ID = ID()
    public let content: String
    
    public init(_ content: String) {
        self.content = content
    }
    
    
    // MARK: value
    public struct ID: Sendable, Hashable {
        public let rawValue = UUID()
    }
}
