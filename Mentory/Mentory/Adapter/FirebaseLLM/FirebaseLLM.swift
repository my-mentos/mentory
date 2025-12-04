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


// MARK: Interface
protocol FirebaseLLMInterface: Sendable {
    func question(_ : FirebaseQuestion) async throws -> FirebaseAnswer
    
    func getEmotionAnalysis(_ : FirebaseQuestion,
                            character: MentoryCharacter) async throws -> FirebaseAnalysis
}



// MARK: Domain
nonisolated
struct FirebaseLLM: FirebaseLLMInterface {
    // MARK: core
    private let logger = Logger(subsystem: "MentoryiOS.FirebaseLLM", category: "Domain")
    private let ai: FirebaseAI
    private let model: GenerativeModel

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash-lite")
    }

    // MARK: flow
    @concurrent
    func question(_ question: FirebaseQuestion) async throws -> FirebaseAnswer {
        logger.info("Firebase LLM 요청 시작")

        do {
            let content = buildModelContent(from: question)
            let response = try await model.generateContent([content])

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
    
    @concurrent
    func getEmotionAnalysis(_ question: FirebaseQuestion, character: MentoryCharacter) async throws -> FirebaseAnalysis {
        logger.info("Firebase LLM 요청 시작")
        
        let jsonSchema = Schema.object(
            properties: [
                "mindType": .enumeration(values: Emotion.getAllEmotions() ),
                "empathyMessage": .string(description: character.messageDescription),
                "actionKeywords": Schema.array(
                    items: .string(description: "사용자의 감정 상태에 따른 행동 추천"),
                    minItems: 3,
                    maxItems: 3),
            ])
        
        let newModel = ai.generativeModel(
          modelName: "gemini-2.5-flash-lite",
          // In the generation config, set the `responseMimeType` to `application/json`
          // and pass the JSON schema object into `responseSchema`.
          generationConfig: GenerationConfig(
            responseMIMEType: "application/json",
            responseSchema: jsonSchema
          )
        )

        let content = buildModelContent(from: question)
        let response = try await newModel.generateContent([content])
        guard let data = response.text?.data(using: .utf8) else {
            throw Error.jsonDecodingFailed
        }
        
        let analysis = try JSONDecoder().decode(FirebaseAnalysis.self, from: data)
        return analysis
    }


    // MARK: helper
    private func buildModelContent(from question: FirebaseQuestion) -> ModelContent {
        var parts: [any Part] = []

        // 텍스트 추가
        parts.append(TextPart(question.content))
        logger.debug("텍스트 콘텐츠 추가됨")

        // 이미지 추가 (최대 1개)
        if let imageData = question.imageData {
            parts.append(InlineDataPart(data: imageData, mimeType: "image/jpeg"))
            logger.info("이미지 데이터 전송 준비 완료 (크기: \(imageData.count) bytes)")
        }

        // 음성 추가 (최대 1개, m4a 포맷)
        if let voiceURL = question.voiceURL {
            parts.append(FileDataPart(uri: voiceURL.absoluteString, mimeType: "audio/m4a"))
            logger.info("음성 파일 전송 준비 완료 (경로: \(voiceURL.lastPathComponent))")
        }

        return ModelContent(role: "user", parts: parts)
    }


    // MARK: value
    enum Error: Swift.Error {
        case emptyResponse
        case jsonDecodingFailed
    }
}
