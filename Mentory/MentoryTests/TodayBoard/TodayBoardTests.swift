//
//  TodayBoardTests.swift
//  Mentory
//
//  Created by SJS on 11/14/25.
//

import Testing
import Foundation
import Values
@testable import Mentory


// MARK: Tests
@Suite("TodayBoard")
struct TodayBoardTests {
    struct SetUpMentorMessage {
        let mentory: MentoryiOS
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await MentoryiOS()
            self.todayBoard = try await getTodayBoardForTest(mentory)
        }
        
        @Test func createMentorMessage() async throws {
            // given
            try await #require(todayBoard.mentorMessage == nil)
            
            // when
            await todayBoard.setUpMentorMessage()
            
            // then
            await #expect(todayBoard.mentorMessage != nil)
        }
        @Test func whenAlreadySetUp() async throws {
            // given
            await todayBoard.setUpMentorMessage()
            
            let mentorMessage = try #require(await todayBoard.mentorMessage)
            
            // when
            await todayBoard.setUpMentorMessage()
            
            // then
            await #expect(todayBoard.mentorMessage?.id == mentorMessage.id)
        }
    }
}


// MARK: Helphers
private func getTodayBoardForTest(_ mentoryiOS: MentoryiOS) async throws -> TodayBoard {
    
    // create Onboarding
    await mentoryiOS.setUp()
    
    let onboarding = try #require(await mentoryiOS.onboarding)
    
    // create TodayBoard
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    await onboarding.next()
    
    let todayBoard = try #require(await mentoryiOS.todayBoard)
    
    return todayBoard
}
