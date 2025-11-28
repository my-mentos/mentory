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

struct FirebaseLLM: Sendable {

    struct Question {
        let content: String

        init(_ content: String) {
            self.content = content
        }
    }

    struct Answer {
        let content: String
    }

    enum Error: Swift.Error {
        case emptyResponse
    }

    private let logger = Logger(subsystem: "MentoryiOS.FirebaseLLM", category: "Domain")
    private let model: GenerativeModel

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash-lite")
    }


    func question(_ question: Question) async throws -> Answer {
        logger.info("Firebase LLM 요청 시작")

        do {
            let response = try await model.generateContent(question.content)

            guard let rawText = response.text,
                  rawText.isEmpty == false else {
                logger.error("Firebase LLM 응답이 비어있음")
                throw Error.emptyResponse
            }

            // ```json 코드블록 감싸져 있으면 제거
            let cleaned = Self.stripCodeFence(from: rawText)

            logger.info("Firebase LLM 응답 성공: \(cleaned, privacy: .public)")
            return Answer(content: cleaned)
        } catch {
            logger.error("Firebase LLM 오류: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }


    // ```json ... ``` 같이 코드블록으로 감싸진 응답에서 앞뒤 ``` 제거
    private static func stripCodeFence(from text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if result.hasPrefix("```") {
            if let firstNewline = result.range(of: "\n") {
                result = String(result[firstNewline.upperBound...])
            }
            if let closingRange = result.range(of: "```", options: .backwards) {
                result = String(result[..<closingRange.lowerBound])
            }
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
