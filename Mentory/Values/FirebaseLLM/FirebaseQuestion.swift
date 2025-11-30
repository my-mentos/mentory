//
//  FirebaseQuestion.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation


// MARK: Value
nonisolated
public struct FirebaseQuestion: Sendable, Hashable {
    public let content: String

    public init(_ content: String) {
        self.content = content
    }
}
