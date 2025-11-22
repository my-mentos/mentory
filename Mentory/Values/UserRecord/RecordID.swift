//
//  RecordID.swift
//  Mentory
//
//  Created by 김민우 on 11/21/25.
//
import Foundation


// MARK: Value
nonisolated
public struct RecordID: Sendable, Hashable {
    // MARK: core
    let value: UUID
    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}
