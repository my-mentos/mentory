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
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard.RecordForm", category: "Domain")
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: TodayBoard?
    
    @Published var mindAnalyzer: MindAnalyzer? = nil

    @Published var titleInput: String = ""
    @Published var textInput: String = ""
    @Published var imageInput: Data? = nil
    @Published var voiceInput: URL? = nil
    
    @Published var canProceed: Bool = false
    
    var startTime: Date? = nil // 기록 시작 시간 (RecordFormView가 열릴 때 설정됨)
    var completionTime: TimeInterval? = nil // 기록 완성까지 걸린 시간
    
    
    // MARK: action
    func validateInput() {
        // capture
        let title = self.titleInput
        guard title.isEmpty == false else {
            logger.error("titleInput에는 값이 존재해야 합니다. 현재 값이 비어있습니다.")
            return
        }
        
        let text = self.textInput
        guard text.isEmpty == false else {
            logger.error("textInput에는 값이 존재해야 합니다. 현재 값이 비어있습니다.")
            return
        }

        // mutate
        self.canProceed = true
    }
    func submit() {
        // capture
        guard titleInput.isEmpty == false else {
            logger.error("RecordForm의 titleInput에는 값이 존재해야 합니다. 현재 값이 비어있습니다.")
            return
        }
        if titleInput.isEmpty {
            
            return
        } else if textInput.isEmpty && voiceInput == nil && imageInput == nil {
            logger.error("RecordForm의 내용 입력이 비어있습니다. 텍스트, 이미지, 음성 중 하나 이상의 값이 필요합니다.")
            return
        }

        // 기록 완성까지 걸린 시간 계산 및 저장
        if let startTime = startTime {
            self.completionTime = Date().timeIntervalSince(startTime)
            logger.info("기록 완성 시간: \(self.completionTime!)초")
        } else {
            logger.warning("startTime이 설정되지 않았습니다.")
        }

        // mutate
        self.mindAnalyzer = MindAnalyzer(owner: self)
    }
    
    func removeForm() {
        // capture
        let todayBoard = self.owner!
        
        // mutate
        todayBoard.recordForm = nil
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
}
