//
//  FirebaseLLM.swift
//  Mentory
//
//  Created by SJS on 11/27/25.
//
import Foundation
import OSLog
import FirebaseCore
import FirebaseAI
import Values





// MARK: Domain
struct FirebaseLLM: Sendable {
    // MARK: core
    private let logger = Logger(subsystem: "MentoryiOS.FirebaseLLM", category: "Domain")
    private let model: GenerativeModel

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash-lite")
    }

    // MARK: flow
    func question(_ question: FirebaseQuestion) async throws -> FirebaseAnswer {
        logger.info("Firebase LLM 요청 시작")

        do {
            let response = try await model.generateContent(question.content)

            guard let rawText = response.text,
                  rawText.isEmpty == false else {
                logger.error("Firebase LLM 응답이 비어있음")
                throw Error.emptyResponse
            }

            let answer = FirebaseAnswer(rawText)
            let cleanedAnswer = answer.removeCodeBlockFence()
            logger.info("Firebase LLM 응답 성공: \(cleanedAnswer.content, privacy: .public)")
            
            return cleanedAnswer
        } catch {
            logger.error("Firebase LLM 오류: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    
    
    // MARK: value
    enum Error: Swift.Error {
        case emptyResponse
    }
}
