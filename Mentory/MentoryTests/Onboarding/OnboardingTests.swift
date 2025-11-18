//
//  OnboardingTests.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Testing
import Foundation
@testable import Mentory


// MARK: Tests
@Suite("Onboarding", .timeLimit(.minutes(1)))
struct OnboardingTests {
    struct ValidateInput {
        let mentoryiOS: MentoryiOS
        let onboarding: Onboarding
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.onboarding = try await getOnboardingForTest(mentoryiOS)
        }
        
        @Test func whenNameInputIsEmpty() async throws {
            // given
            try await #require(onboarding.nameInput.isEmpty)
            try await #require(onboarding.validationResult == .none)
            
            await #expect(onboarding.validationResult == .none)
            
            // when
            await onboarding.validateInput()
            
            // then
            await #expect(onboarding.validationResult == .nameInputIsEmpty)
        }
        @Test func resetResult_WhenNameInputIsEmpty() async throws {
            // given
            await MainActor.run {
                onboarding.validationResult = .nameInputIsEmpty
            }
            
            await onboarding.setName("TEST_USER_NAME")
            
            try await #require(onboarding.validationResult != .none)
            try await #require(onboarding.nameInput.isEmpty == false)
            
            // when
            await onboarding.validateInput()
            
            // then
            await #expect(onboarding.validationResult == .none)
        }
        @Test func whenNameInputIsNotEmpty() async throws {
            // given
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            
            try await #require(onboarding.validationResult == .none)
            
            // when
            await onboarding.validateInput()
            
            // then
            await #expect(onboarding.validationResult == .none)
        }
    }
        
    struct Next {
        let mentoryiOS: MentoryiOS
        let onboarding: Onboarding
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.onboarding = try await getOnboardingForTest(mentoryiOS)
        }
        
        @Test func whenNameInputIsEmpty() async throws {
            // given
            let onboardingFormMentory = try #require(await mentoryiOS.onboarding)
            try await #require(mentoryiOS.onboarding != nil)
            try await #require(mentoryiOS.onboardingFinished == false)
            try await #require(mentoryiOS.todayBoard == nil)
            try await #require(mentoryiOS.settingBoard == nil)
            
            // when
            await onboarding.next()
            
            // then
            await #expect(mentoryiOS.onboarding?.id == onboardingFormMentory.id)
            await #expect(mentoryiOS.onboardingFinished == false)
            await #expect(mentoryiOS.todayBoard == nil)
            await #expect(mentoryiOS.settingBoard == nil)
        }
        @Test func whenIsUsedIsTrue() async throws {
            // given
            await onboarding.setName("TEST_USER_NAME")
            await onboarding.next()
            
            try await #require(onboarding.isUsed == true)
            
            let oldTodayBoard = try #require(await mentoryiOS.todayBoard)
            let oldSettingBoard = try #require(await mentoryiOS.settingBoard)
            
            // when
            await onboarding.next()
            
            // then
            await #expect(mentoryiOS.todayBoard?.id == oldTodayBoard.id)
            await #expect(mentoryiOS.settingBoard?.id == oldSettingBoard.id)
        }
        
        @Test func setIsUsedTrue() async throws {
            // given
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            
            try await #require(onboarding.isUsed == false)
            
            // when
            await onboarding.next()
            
            // then
            await #expect(onboarding.isUsed == true)
        }
        
        @Test func MentoryiOS_setUserName() async throws {
            // given
            try await #require(mentoryiOS.userName == nil)
            
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            try await #require(onboarding.nameInput.isEmpty == false)
            
            
            // when
            await onboarding.next()
            
            // then
            await #expect(mentoryiOS.userName == testUserName)
        }
        @Test func MentoryiOS_removeOnboarding() async throws {
            // given
            try await #require(mentoryiOS.onboarding != nil)
            
            await onboarding.setName("TEST_USER_NAME")
            
            // when
            await onboarding.next()
            
            // then
            await #expect(mentoryiOS.onboarding == nil)
        }
        @Test func MentoryiOS_setOnBoardingFinished() async throws {
            // given
            try await #require(mentoryiOS.onboardingFinished == false)
            
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            try await #require(onboarding.nameInput.isEmpty == false)
            
            // when
            await onboarding.next()
            
            // then
            await #expect(mentoryiOS.onboardingFinished == true)
        }
        @Test func MentoryiOS_createTodayBoard() async throws {
            // given
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            
            try await #require(mentoryiOS.todayBoard == nil)
            
            // when
            await onboarding.next()
            
            // then
            await #expect(mentoryiOS.todayBoard != nil)
        }
        @Test func TodayBoard_createRecordForm() async throws {
            // given
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            
            try await #require(mentoryiOS.todayBoard == nil)
            
            // when
            await onboarding.next()
            
            // then
            let todayBoard = try #require(await mentoryiOS.todayBoard)
            await #expect(todayBoard.recordForm != nil)
        }
        @Test func MentoryiOS_createSettingBoard() async throws {
            // given
            await onboarding.setName("TEST_USER_NAME")
            
            try await #require(mentoryiOS.settingBoard == nil)
            
            // when
            await onboarding.next()
            
            // then
            await #expect(mentoryiOS.settingBoard != nil)
        }
    }
}


// MARK: Helphers
private func getOnboardingForTest(_ mentoryiOS: MentoryiOS) async throws -> Onboarding {
    // create Onboarding
    try await #require(mentoryiOS.onboarding == nil)
    
    await mentoryiOS.setUp()
    
    let onBoarding = try #require(await mentoryiOS.onboarding)
    return onBoarding
}

