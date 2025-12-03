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
    
    struct SetUpRecordForms {
        let mentory: MentoryiOS
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await MentoryiOS()
            self.todayBoard = try await getTodayBoardForTest(mentory)
        }
        
        @Test func createRecordForms() async throws {
            // given
            try await #require(todayBoard.recordForms.isEmpty == true)
            
            // when
            await todayBoard.setUpRecordForms()
            
            // then
            await #expect(todayBoard.recordForms.isEmpty == false)
        }
        @Test func createThreeRecordForms() async throws {
            // given
            try await #require(todayBoard.recordForms.count == 0)
            
            // when
            await todayBoard.setUpRecordForms()
            
            // then
            await #expect(todayBoard.recordForms.count == 3)
        }
        
        @Test func createTodayRecordForm() async throws {
            // given
            let today = MentoryDate.now
            
            try await #require(todayBoard.recordForms.isEmpty)
            
            // when
            await todayBoard.setUpRecordForms()
            
            // then
            try await #require(todayBoard.recordForms.count == 3)
            
            let firstIndex = await todayBoard.recordForms
                .startIndex
            
            let recordForm = await todayBoard.recordForms[firstIndex]
            
            let date = recordForm.targetDate
            
            #expect(date.isSameDate(as: today))
        }
        @Test func createYesterDayRecordForm() async throws {
            // given
            let yesterday = MentoryDate.now.dayBefore()
            
            try await #require(todayBoard.recordForms.isEmpty)
            
            // when
            await todayBoard.setUpRecordForms()
            
            // then
            try await #require(todayBoard.recordForms.count == 3)
            
            let secondIndex = await todayBoard.recordForms
                .startIndex
                .advanced(by: 1)
            
            let recordForm = await todayBoard.recordForms[secondIndex]
            
            let date = recordForm.targetDate
            
            #expect(date.isSameDate(as: yesterday))
        }
        @Test func createTwoDaysAgoRecordForm() async throws {
            // given
            let twoDaysAgo = MentoryDate.now
                .twoDaysBefore()
            
            try await #require(todayBoard.recordForms.isEmpty)
            
            // when
            await todayBoard.setUpRecordForms()
            
            // then
            try await #require(todayBoard.recordForms.count == 3)
            
            let thirdIndex = await todayBoard.recordForms
                .startIndex
                .advanced(by: 2)
            
            let recordForm = await todayBoard.recordForms[thirdIndex]
            
            let date = recordForm.targetDate
            
            #expect(date.isSameDate(as: twoDaysAgo))
        }
    }
    
    struct UpdateRecordForms {
        let mentory: MentoryiOS
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await MentoryiOS()
            self.todayBoard = try await getTodayBoardForTest(mentory)
        }
    }
    
    struct SetUpSuggestion {
        let mentory: MentoryiOS
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await MentoryiOS()
            self.todayBoard = try await getTodayBoardForTest(mentory)
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
