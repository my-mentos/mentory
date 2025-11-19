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
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard.RecordForm", category: "Domain")
    weak var owner: TodayBoard?
    var mindAnalyzer: MindAnalyzer? = nil
    
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
        let title = self.titleInput
        let text = self.textInput
        let image = self.imageInput
        let voice = self.voiceInput

        if titleInput.isEmpty {
            logger.error("RecordForm의 titleInput에는 값이 존재해야 합니다. 현재 값이 비어있습니다.")
            return
        } else if textInput.isEmpty && voiceInput == nil && imageInput == nil {
            logger.error("RecordForm의 내용 입력이 비어있습니다. 텍스트, 이미지, 음성 중 하나 이상의 값이 필요합니다.")
            return
        }

        let todayBoard = self.owner

        // mutate
        let record = Record(
            title: title,
            date: Date(), // 오늘 날짜
            text: text.isEmpty ? nil : text,
            image: image,
            voice: voice
        )

        // todayBoard에 저장
        todayBoard?.records.append(record)
        logger.info("새로운 기록이 추가되었습니다. ID: \(record.id)")
        
        self.mindAnalyzer = MindAnalyzer(owner: self)
    }

    // MARK: value
    nonisolated struct Record: Identifiable, Sendable, Hashable {
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
