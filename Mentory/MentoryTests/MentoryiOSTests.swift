//
//  MentoryiOSTests.swift
//  MentoryiOSTests
//
//  Created by 김민우 on 11/13/25.
//
import Testing
@testable import Mentory
import MentoryDBAdapter


// MARK: Tests
@Suite("MentoryiOS", .timeLimit(.minutes(1)))
struct MentoryiOSTests {
    struct SetUp {
        let mentoryiOS: MentoryiOS
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
        }
        
        @Test func createOnboarding() async throws {
            // given
            try await #require(mentoryiOS.onboarding == nil)
            
            // when
            await mentoryiOS.setUp()
            
            // then
            await #expect(mentoryiOS.onboarding != nil)
        }
        
        @Test func whenUserNameAlreadySet() async throws {
            // given
            await MainActor.run {
                mentoryiOS.userName = "TEST_USERNAME"
            }
            
            // when
            await mentoryiOS.setUp()
            
            // then
            await #expect(mentoryiOS.onboarding == nil)
        }
        @Test func whenOnboardingAlreadySet() async throws {
            // given
            let testOnboarding = await Onboarding(owner: mentoryiOS)
            await MainActor.run {
                mentoryiOS.onboarding = testOnboarding
            }
            
            // when
            await mentoryiOS.setUp()
            
            // then
            await #expect(mentoryiOS.onboarding?.id == testOnboarding.id)
        }
        @Test func whenOnboardingFinished() async throws {
            // given
            let testOnboarding = await Onboarding(owner: mentoryiOS)
            await MainActor.run {
                mentoryiOS.onboardingFinished = true
                mentoryiOS.onboarding = testOnboarding
            }
            
            // when
            await mentoryiOS.setUp()
            
            // then
            await #expect(mentoryiOS.onboarding?.id == testOnboarding.id)
        }
    }
    
    struct SaveUserName {
        let mentoryiOS: MentoryiOS
        let mentoryDB: any MentoryDBInterface
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.mentoryDB = mentoryiOS.mentoryDB
        }
        
        @Test func setUserName() async throws {
            // given
            try await #require(mentoryDB.getName() == nil)
            
            await MainActor.run {
                mentoryiOS.userName = "TEST_USER_NAME"
            }
            
            // when
            await mentoryiOS.saveUserName()
            
            // then
            try await #expect(mentoryDB.getName() == "TEST_USER_NAME")
        }
    }
    
    struct LoadUserName {
        let mentoryiOS: MentoryiOS
        let mentoryDB: any MentoryDBInterface
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.mentoryDB = mentoryiOS.mentoryDB
        }
        
        @Test func setOnboardingNil() async throws {
            // given
            try await mentoryDB.setName("TEST_USER_NAME")
            
            // when
            await mentoryiOS.loadUserName()
            
            // then
            await #expect(mentoryiOS.onboarding == nil)
        }
        @Test func setOnboardingFinishedTrue() async throws {
            // given
            try await mentoryDB.setName("TEST_USER_NAME")
            
            try await #require(mentoryiOS.onboardingFinished == false)
            
            // when
            await mentoryiOS.loadUserName()
            
            // then
            await #expect(mentoryiOS.onboardingFinished == true)
        }
        
        @Test func createSettingBoard() async throws {
            // given
            try await mentoryDB.setName("TEST_USER_NAME")
            
            try await #require(mentoryiOS.settingBoard == nil)
            
            // when
            await mentoryiOS.loadUserName()
            
            // then
            await #expect(mentoryiOS.settingBoard != nil)
        }
    }
}


// MARK: Helpher
