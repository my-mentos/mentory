//
//  RecordForm.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
//

import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class RecordForm: Sendable, ObservableObject {
    // MARK: core
    init(owner: TodayBoard) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    nonisolated let owner: TodayBoard
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard.RecordForm", category: "Domain")
    
    @Published var titleInput: String = ""
    @Published var textInput: String = ""
    @Published var imageInput: Data? = nil
    @Published var voiceInput: URL? = nil
    @Published var validationResult: ValidationResult = .none
    
    
    // MARK: action
    func validateInput() {
        // capture
        let currentTitleInput = self.titleInput
        let currentTextInput = self.textInput
        let currentImageInput = self.imageInput
        let currentVoiceInput = self.voiceInput

        // mutate
        if currentTitleInput.isEmpty {
            self.validationResult = .titleInputIsEmpty
            return
        } else if currentTextInput.isEmpty && currentVoiceInput == nil && currentImageInput == nil {
            self.validationResult = .contentsInputIsEmpty
            return
        } else {
            // 모든 검증 통과
            self.validationResult = .none
        }
    }
    
    func submit() {
        // capture
        validateInput()

        guard validationResult == .none else {
            logger.error("RecordForm의 입력값이 유효하지 않습니다.")
            return
        }

        let todayBoard = self.owner

        // mutate
        // Record 객체 생성 (입력받은 것만 포함)
        let record = Record(
            title: titleInput,
            date: Date(), // 오늘 날짜
            text: textInput.isEmpty ? nil : textInput,
            image: imageInput,
            voice: voiceInput
        )

        // todayBoard에 저장
        addRecord(record, to: todayBoard)

        // form 초기화
        self.titleInput = ""
        self.textInput = ""
        self.imageInput = nil
        self.voiceInput = nil
        self.validationResult = .none

        logger.info("기록이 성공적으로 제출되었습니다.")
    }

    func addRecord(_ record: Record, to todayBoard: TodayBoard) {
        todayBoard.records.append(record)
        logger.info("새로운 기록이 추가되었습니다. ID: \(record.id)")
    }


    // MARK: value
    struct Record: Identifiable, Sendable, Hashable {
        let id: UUID
        let title: String
        let date: Date
        let text: String?
        let image: Data?
        let voice: URL?

        init(id: UUID = UUID(), title: String, date: Date, text: String? = nil, image: Data? = nil, voice: URL? = nil) {
            self.id = id
            self.title = title
            self.date = date
            self.text = text
            self.image = image
            self.voice = voice
        }
    }

    nonisolated enum ValidationResult: String, Sendable, Hashable {
        case none
        case titleInputIsEmpty
        case contentsInputIsEmpty
    }
}
