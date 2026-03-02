//
//  TodayBoardTests.swift
//  Mentory
//
//  Created by SJS on 11/14/25.
//

import Testing
import Foundation
import Values
@testable import MentoryCore


// MARK: Tests
@Suite("TodayBoard")
struct TodayBoardTests {
    struct SetUpMentorMessage {
        let mentory: Mentory
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await Mentory()
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
        let mentory: Mentory
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await Mentory()
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
        
        @Test func whenAlreadySetUpNotCreateRecordFormAgain() async throws {
            // given
            await todayBoard.setUpRecordForms()
            
            try await #require(todayBoard.recordForms.isEmpty == false)
            
            let recordForms = await todayBoard.recordForms
            let recordFormIds = recordForms.map { $0.id }
            let recordFormIdSet = Set(recordFormIds)
            
            // when
            await todayBoard.setUpRecordForms()
            
            // then
            let newRecordForms = await todayBoard.recordForms
            let newRecordFormIds = newRecordForms.map { $0.id }
            let newRecordFormIdSet = Set(newRecordFormIds)
            
            #expect(newRecordFormIdSet == recordFormIdSet)
        }
    }
    
    struct UpdateRecordForms {
        let mentory: Mentory
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await Mentory()
            self.todayBoard = try await getTodayBoardForTest(mentory)
        }
        
        @Test func whenNotSetUpRecordForms() async throws {
            // given
            try await #require(todayBoard.recordForms.isEmpty == true)
            
            // when
            await todayBoard.updateRecordForms()
            
            // then
            await #expect(todayBoard.recordForms.isEmpty == true)
        }
        @Test func NotUpdateWhenIsSameDay() async throws {
            // given
            await todayBoard.setUpRecordForms()
            
            try await #require(todayBoard.recordForms.isEmpty == false)
            
            let recordForms = await todayBoard.recordForms
            let recordFormIds = recordForms.map { $0.id }
            let recordFormIdSet = Set(recordFormIds)
            
            let date = await todayBoard.currentDate
            let randomSameDate = date.randomTimeInSameDay()
            
            await todayBoard.setCurrentDate(randomSameDate)
            
            // when
            await todayBoard.updateRecordForms()
            
            // then
            let newRecordForms = await todayBoard.recordForms
            let newRecordFormIds = newRecordForms.map { $0.id }
            let newRecordFormIdSet = Set(newRecordFormIds)
            
            #expect(newRecordFormIdSet == recordFormIdSet)
        }
        
        @Test func removeStaleRecordFormWhenDayChanged() async throws {
            // given
            await todayBoard.setUpRecordForms()
            try await #require(todayBoard.recordForms.count == 3)
            
            let optionalRecordForm = await todayBoard.recordForms
                .first { recordForm in
                    recordForm.targetDate.relativeDay(from: .now) == .dayBefoeYesterday
                }
            let twoDaysAgoRecordForm = try #require(optionalRecordForm)
            
            // given
            let baseDate = try #require(await todayBoard.recentUpdatedate())
            let nextDate = baseDate.dayAfter()
            await todayBoard.setCurrentDate(nextDate)

            
            // when
            await todayBoard.updateRecordForms()
            
            
            // then
            try await #require(todayBoard.recordForms.count == 3)
            
            let isExist = await todayBoard.recordForms
                .contains { $0.id == twoDaysAgoRecordForm.id }
            
            #expect(isExist == false)
        }
        @Test func createRecordFormWhenDayChanged() async throws {
            // given
            await todayBoard.setUpRecordForms()
            try await #require(todayBoard.recordForms.count == 3)
            
            let beforeRecordForms = await todayBoard.recordForms
            let beforeIdSet = Set(beforeRecordForms.map(\.id))
            
            let baseDate = try #require(await todayBoard.recentUpdatedate())
            let nextDate = baseDate.dayAfter()
            await todayBoard.setCurrentDate(nextDate)
            
            
            // when
            await todayBoard.updateRecordForms()
            
            
            // then
            try await #require(todayBoard.recordForms.count == 3)
            
            let afterRecordForms = await todayBoard.recordForms
            let afterIdSet = Set(afterRecordForms.map(\.id))
            
            // 새로 생긴 id 1개
            let diff = afterIdSet.subtracting(beforeIdSet)
            let newId = try #require(diff.first)
            #expect(diff.count == 1)
            
            let newRecordForm = try #require(await todayBoard.recordForms
                .first { $0.id == newId }
            )
            let newRecordFormDate = newRecordForm.targetDate
            
            // 새 폼의 날짜는 nextDate(= 새로운 오늘)이 되어야 한다
            #expect(newRecordFormDate.isSameDate(as: nextDate))
            
            // recentSetUpDate도 nextDate로 갱신되었는지 확인
            let recent = try #require(await todayBoard.recentUpdatedate())
            #expect(recent.isSameDate(as: nextDate))
        }
    }
    
    struct LoadSuggestions {
        let mentory: Mentory
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await Mentory()
            self.todayBoard = try await getTodayBoardForTest(mentory)
        }
        
        @Test(.disabled()) func whenAlreadySetUp() async throws {
            // given
            await todayBoard.loadSuggestions()
            
            try await #require(todayBoard.suggestions.count == 3)
            
            // when
            await todayBoard.loadSuggestions()
            
            // then
            Issue.record("테스트 작성 예정")
        }
    }
}


// MARK: Helphers
private func getTodayBoardForTest(_ mentoryiOS: Mentory) async throws -> TodayBoard {
    
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
