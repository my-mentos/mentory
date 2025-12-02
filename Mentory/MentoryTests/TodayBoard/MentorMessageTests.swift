//
//  MentorMessageTests.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation
import Testing
@testable import Mentory


// MARK: Tests
@Suite
struct MentorMessageTests {
    struct SetRandomCharacter {
        
    }
}


// MARK: Helpher
private func getMentorMessage(_ mentoryiOS: MentoryiOS) async throws -> MentorMessage {
    await mentoryiOS.setUp()
    
    // create Onboarding
    await mentoryiOS.setUp()
    
    let onboarding = try #require(await mentoryiOS.onboarding)
    
    // create TodayBoard
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    await onboarding.next()
    
    let todayBoard = try #require(await mentoryiOS.todayBoard)
    
    // create MentorMessage
    await todayBoard.setUpMentorMessage()
    
    let mentorMessage = try #require(await todayBoard.mentorMessage)
    
    return mentorMessage
}
