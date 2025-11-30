//
//  RecordFormTests.swift
//  MentoryiOSTests
//
//  Created by 구현모 on 11/15/25.
//

import Testing
@testable import Mentory
import Foundation

// MARK: Tests
@Suite("RecordForm", .timeLimit(.minutes(1)))
struct RecordFormTests {
    struct ValidateInput {
        let mentoryiOS: MentoryiOS
        let recordForm: RecordForm
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.recordForm = try await getRecordFormForTest(mentoryiOS)
        }

        // 실패 케이스
        @Test func whenTitleIsEmpty() async throws {
            // Given: 제목이 비어있고 텍스트만 있음
            await MainActor.run {
                recordForm.titleInput = ""
                recordForm.textInput = "내용"
            }
            
            try await #require(recordForm.canProceed == false)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.canProceed == false)
        }
        @Test func whenAllContentsAreEmpty() async throws {
            // given
            await MainActor.run {
                recordForm.titleInput = "제목"
                recordForm.textInput = ""
                recordForm.imageInput = nil
                recordForm.voiceInput = nil
            }
            
            try await #require(recordForm.canProceed == false)

            // when
            await recordForm.validateInput()

            // then
            await #expect(recordForm.canProceed == false)
        }

        // 성공 케이스
        @Test func whenTitleAndTextExist() async throws {
            // Given
            await MainActor.run {
                recordForm.titleInput = "SAMPLE_TITLE"
                recordForm.textInput = "SAMPLE_TEXT"
            }
            
            try await #require(recordForm.canProceed == false)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.canProceed == true)
        }
        @Test func whenTextInputIsEmpty() async throws {
            // Given
            await MainActor.run {
                recordForm.titleInput = "제목"
                recordForm.imageInput = Data([0x00, 0x01, 0x02])
                recordForm.voiceInput = URL(string: "file:///path/to/voice.m4a")
            }
            
            try await #require(recordForm.canProceed == false)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.canProceed == false)
        }
        @Test func whenAllInputsExist() async throws {
            // Given
            await MainActor.run {
                recordForm.titleInput = "제목"
                recordForm.textInput = "내용"
                recordForm.imageInput = Data([0x00, 0x01, 0x02])
                recordForm.voiceInput = URL(string: "file:///path/to/voice.m4a")
            }
            
            try await #require(recordForm.canProceed == false)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.canProceed == true)
        }
    }

    struct Submit {
        let mentoryiOS: MentoryiOS
        let recordForm: RecordForm
        let todayBoard: TodayBoard
        
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.recordForm = try await getRecordFormForTest(mentoryiOS)
            self.todayBoard = try #require(await mentoryiOS.todayBoard)
        }

        
        @Test func notResetTitleInputWhenSucceed() async throws {
            // given
            let testTitle = "TEST_TITLE"
            await MainActor.run {
                recordForm.titleInput = testTitle
            }
            
            // when
            await recordForm.submit()
            
            // then
            await #expect(recordForm.titleInput == testTitle)
        }
        @Test func notResetTextInputWhenSucceed() async throws {
            // given
            let testText = "TEST_TEXT"
            await MainActor.run {
                recordForm.textInput = testText
            }
            
            // when
            await recordForm.submit()
            
            // then
            await #expect(recordForm.textInput == testText)
        }
        @Test func notResetImageInputWhenSucceed() async throws {
            // given
            let testImageData: Data = .init([0x00, 0x01])
            await MainActor.run {
                recordForm.imageInput = testImageData
            }
            
            // when
            await recordForm.submit()
            
            // then
            await #expect(recordForm.imageInput == testImageData)
        }
        @Test func notResetVoiceInputWhenSucceed() async throws {
            // given
            let testVoiceURL = URL(string: "file:///test.m4a")!
            await MainActor.run {
                recordForm.voiceInput = testVoiceURL
            }
            
            // when
            await recordForm.submit()
            
            // then
            await #expect(recordForm.voiceInput == testVoiceURL)
        }
    }
    
    struct RemoveForm {
        let mentoryiOS: MentoryiOS
        let recordForm: RecordForm
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.recordForm = try await getRecordFormForTest(mentoryiOS)
        }
        
        @Test func deleteRecordForm() async throws {
            // given
            let todayBoard = try #require(await recordForm.owner)
            
            try await #require(todayBoard.recordForm != nil)
            
            // when
            await recordForm.removeForm()
            
            // then
            await #expect(todayBoard.recordForm == nil)
        }
    }
}

// MARK: Helpers
private func getRecordFormForTest(_ mentoryiOS: MentoryiOS) async throws -> RecordForm {
    // MentoryiOS
    await mentoryiOS.setUp()
    
    // Onboarding
    let onboarding = try #require(await mentoryiOS.onboarding)
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    await onboarding.next()
    
    // TodayBoard
    let todayBoard = try #require(await mentoryiOS.todayBoard)
    await todayBoard.setUpForm()
    
    // RecordForm
    let recordForm = try #require(await todayBoard.recordForm)
    return recordForm
}
