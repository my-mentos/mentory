//
//  MentoryWatch.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
public final class MentoryWatch: Sendable {
    // MARK: core
    
    
    // MARK: state
    var todayBoard: TodayBoard? = nil
    var actionBoard: ActionBoard? = nil
    
    
    // MARK: action
    public func setUp() async {
        // capture
        
        // process
        
        // mutate
        self.todayBoard = TodayBoard(owner: self)
        self.actionBoard = ActionBoard(owner: self)
    }
}
