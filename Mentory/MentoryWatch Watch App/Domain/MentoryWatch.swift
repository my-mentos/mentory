//
//  MentoryWatch.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import Foundation
import OSLog


// MARK: Object
@MainActor @Observable
public final class MentoryWatch: Sendable {
    // MARK: core
    nonisolated let logger = Logger(subsystem: "MentoryWatch", category: "Domain")
    
    
    
    // MARK: state
    var isSetUp: Bool = false
    var todayBoard: TodayBoard? = nil
    var actionBoard: ActionBoard? = nil
    
    
    // MARK: action
    public func setUp() async {
        // capture
        guard self.isSetUp == false else {
            logger.error("이미 세팅되어 있습니다.")
            return
        }
        
        
        // mutate
        self.todayBoard = TodayBoard(owner: self)
        self.actionBoard = ActionBoard(owner: self)
        self.isSetUp = true
    }
}
