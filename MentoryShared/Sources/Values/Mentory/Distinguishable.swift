//
//  Distinguishable.swift
//  Values
//
//  Created by 김민우 on 1/2/26.
//
import Foundation


// MARK: Interface
public protocol Distinguishable: Identifiable, Hashable { }

public extension Distinguishable {
    /// Default equality based on `Identifiable.id`.
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    /// Default hashing based on `Identifiable.id`.
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
