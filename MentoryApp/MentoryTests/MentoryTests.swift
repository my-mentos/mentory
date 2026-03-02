//
//  MentoryTests.swift
//  MentoryTests
//
//  Created by 김민우 on 11/13/25.
//
import Testing
@testable import MentoryCore
import MentoryDBAdapter


// MARK: Tests
@Suite("Mentory", .timeLimit(.minutes(1)))
struct MentoryTests {
    struct Init {
        let mentory: Mentory
        init() async throws {
            self.mentory = await Mentory()
        }
        
        @Test func isOnboardingBoardIsNil() async throws {
            await #expect(mentory.onboarding == nil)
        }
        @Test func isStatBoardIsNil() async throws {
            await #expect(mentory.statBoard == nil)
        }
    }
    struct SetUp {
        let mentory: Mentory
        init() async throws {
            self.mentory = await Mentory()
        }
        
        @Test func createOnboarding() async throws {
            // given
            try await #require(mentory.onboarding == nil)
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding != nil)
        }
        @Test func setStatisticsBoardNil() async throws {
            // given
            try await #require(mentory.statBoard == nil)
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.statBoard == nil)
        }
        
        @Test func whenUserNameAlreadySet() async throws {
            // given
            await MainActor.run {
                mentory.userName = "TEST_USERNAME"
            }
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding == nil)
        }
        @Test func whenOnboardingAlreadySet() async throws {
            // given
            let testOnboarding = await Onboarding(owner: mentory)
            await MainActor.run {
                mentory.onboarding = testOnboarding
            }
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding?.id == testOnboarding.id)
        }
        @Test func whenOnboardingFinished() async throws {
            // given
            let testOnboarding = await Onboarding(owner: mentory)
            await MainActor.run {
                mentory.onboardingFinished = true
                mentory.onboarding = testOnboarding
            }
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding?.id == testOnboarding.id)
        }
    }
    
    struct SaveUserName {
        let mentory: Mentory
        let mentoryDB: any MentoryDBInterface
        init() async throws {
            self.mentory = await Mentory()
            self.mentoryDB = mentory.mentoryDB
        }
        
        @Test func setUserName() async throws {
            // given
            try await #require(mentoryDB.getName() == nil)
            
            await MainActor.run {
                mentory.userName = "TEST_USER_NAME"
            }
            
            // when
            await mentory.saveUserName()
            
            // then
            try await #expect(mentoryDB.getName() == "TEST_USER_NAME")
        }
    }
    
    struct LoadUserName {
        let mentory: Mentory
        let mentoryDB: any MentoryDBInterface
        init() async throws {
            self.mentory = await Mentory()
            self.mentoryDB = mentory.mentoryDB
        }
        
        @Test func setOnboardingNil() async throws {
            // given
            try await mentoryDB.setName("TEST_USER_NAME")
            
            // when
            await mentory.loadUserName()
            
            // then
            await #expect(mentory.onboarding == nil)
        }
        @Test func setOnboardingFinishedTrue() async throws {
            // given
            try await mentoryDB.setName("TEST_USER_NAME")
            
            try await #require(mentory.onboardingFinished == false)
            
            // when
            await mentory.loadUserName()
            
            // then
            await #expect(mentory.onboardingFinished == true)
        }
        
        @Test func createSettingBoard() async throws {
            // given
            try await mentoryDB.setName("TEST_USER_NAME")
            
            try await #require(mentory.settingBoard == nil)
            
            // when
            await mentory.loadUserName()
            
            // then
            await #expect(mentory.settingBoard != nil)
        }
    }
}


// MARK: Helpher
