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
            
            try await #require(recordForm.validationResult == .none)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.validationResult == .titleInputIsEmpty)
        }
        @Test func whenAllContentsAreEmpty() async throws {
            // Given: 제목만 있고 모든 컨텐츠가 비어있음
            await MainActor.run {
                recordForm.titleInput = "제목"
                recordForm.textInput = ""
                recordForm.imageInput = nil
                recordForm.voiceInput = nil
            }
            
            try await #require(recordForm.validationResult == .none)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.validationResult == .contentsInputIsEmpty)
        }

        // 성공 케이스
        @Test func whenTitleAndTextExist() async throws {
            // Given
            await MainActor.run {
                recordForm.titleInput = "제목"
                recordForm.textInput = "내용"
            }
            
            try await #require(recordForm.validationResult == .none)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.validationResult == .none)
        }
        @Test func whenTitleAndImageExist() async throws {
            // Given
            await MainActor.run {
                recordForm.titleInput = "제목"
                recordForm.imageInput = Data([0x00, 0x01, 0x02])
            }
            
            try await #require(recordForm.validationResult == .none)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.validationResult == .none)
        }
        @Test func whenTitleAndVoiceExist() async throws {
            // Given
            await MainActor.run {
                recordForm.titleInput = "제목"
                recordForm.voiceInput = URL(string: "file:///path/to/voice.m4a")
            }
            
            try await #require(recordForm.validationResult == .none)

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.validationResult == .none)
        }
        @Test func whenAllInputsExist() async throws {
            // Given
            await MainActor.run {
                recordForm.titleInput = "제목"
                recordForm.textInput = "내용"
                recordForm.imageInput = Data([0x00, 0x01, 0x02])
                recordForm.voiceInput = URL(string: "file:///path/to/voice.m4a")
            }

            // When
            await recordForm.validateInput()

            // Then
            await #expect(recordForm.validationResult == .none)
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

        // MARK: 제출 기능 테스트

        func TodayBoard_addRecord() async throws {
            // Given
            await MainActor.run {
                recordForm.titleInput = "테스트 제목"
                recordForm.textInput = "테스트 내용"
            }

            let initialCount = await todayBoard.records.count

            // When
            await recordForm.submit()

            // Then
            let newCount = await todayBoard.records.count
            #expect(newCount == initialCount + 1)
        }

        @Test("제출 후 폼이 초기화되지 않음")
        func afterSubmit_formIsReset() async throws {
            // Given
            let testTitle = "TEST_TITLE"
            let testText = "TEST_TEXT"
            let testImageData: Data = .init([0x00, 0x01])
            let testVoiceURL = URL(string: "file:///test.m4a")!
            
            await MainActor.run {
                recordForm.titleInput = testTitle
                recordForm.textInput = testText
                recordForm.imageInput = testImageData
                recordForm.voiceInput = testVoiceURL
            }

            // When
            await recordForm.submit()

            // Then
            await #expect(recordForm.titleInput == testTitle)
            await #expect(recordForm.textInput == testText)
            await #expect(recordForm.imageInput == testImageData)
            await #expect(recordForm.voiceInput == testVoiceURL)
            await #expect(recordForm.validationResult == .none)
        }

        @Test("유효하지 않은 입력으로 제출 시 Record가 추가되지 않음")
        func whenInvalidInput_recordIsNotAdded() async throws {
            // Given: 제목이 비어있음
            await MainActor.run {
                recordForm.titleInput = ""
                recordForm.textInput = "내용"
            }

            let initialCount = await todayBoard.records.count

            // When
            await recordForm.submit()

            // Then
            let newCount = await todayBoard.records.count
            #expect(newCount == initialCount)
        }

        @Test("빈 텍스트로 제출 시 Record의 text가 nil로 저장됨", .disabled())
        func whenTextIsEmpty_recordTextIsNil() async throws {
            
        }
    }
}

// MARK: Helpers
private func getRecordFormForTest(_ mentoryiOS: MentoryiOS) async throws -> RecordForm {
    // 앱 기본 세팅
    await mentoryiOS.setUp()
    
    // 온보딩 가져오기
    guard let onboarding = await mentoryiOS.onboarding else {
        throw NSError(domain: "Onboarding not initialized", code: -1)
    }
    
    // 온보딩 값 입력 + 검증
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    // 온보딩 완료 
    await onboarding.next()
    
    // TodayBoard 가져오기
    guard let todayBoard = await mentoryiOS.todayBoard else {
        throw NSError(domain: "TodayBoard not initialized", code: -1)
    }
    
    // RecordForm 없으면 생성
    if await todayBoard.recordForm == nil {
        await MainActor.run {
            todayBoard.recordForm = RecordForm(owner: todayBoard)
        }
    }
    
    // RecordForm 리턴
    guard let recordForm = await todayBoard.recordForm else {
        throw NSError(domain: "RecordForm not initialized", code: -1)
    }
    
    return recordForm
}
