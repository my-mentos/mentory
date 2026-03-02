//
//  TodayBoard.swift
//  Mentory
//
//  Created by 김민우 on 12/10/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
public final class TodayBoard: Sendable {
    // MARK: core
    weak var owner: MentoryWatch?
    init(owner: MentoryWatch) {
        self.owner = owner
    }
    
    
    // MARK: state
    public nonisolated let id = UUID()
    
    
    // MARK: action
}
