//
//  MentorMessageTests.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation
import Testing
import Values
@testable import Mentory


// MARK: Tests
@Suite
struct MentorMessageTests {
    struct SetRandomCharacter {
        let mentoryiOS: MentoryiOS
        let mentorMessage: MentorMessage
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.mentorMessage = try await getMentorMessage(mentoryiOS)
        }
        
        @Test func setCharacter() async throws {
            // given
            try await #require(mentorMessage.character == nil)
            
            // when
            await mentorMessage.setRandomCharacter()
            
            // then
            await #expect(mentorMessage.character != nil)
        }
        
        @Test(arguments: MentoryCharacter.allCases) func setCharacterRandomlyOnce(_ character: MentoryCharacter) async throws {
            // given
            await MainActor.run {
                mentorMessage.character = character
            }
            
            // when
            await mentorMessage.setRandomCharacter()
            
            // then
            await #expect(mentorMessage.character == character)
        }
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
