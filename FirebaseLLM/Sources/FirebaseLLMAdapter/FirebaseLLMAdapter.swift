import Values
import OSLog
import FirebaseAI
import FirebaseCore
import Foundation



// MARK: Adapter
public nonisolated struct FirebaseLLMAdapter: FirebaseLLMAdapterInterface {
    // MARK: core
    private let logger = Logger(subsystem: "MentoryiOS.FirebaseLLM", category: "Domain")
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
    public init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash-lite")
    }
    
    
    // MARK: task
    public func question(_ question: FirebaseQuestion) async -> FirebaseAnswer? {
        logger.debug("Firebase LLM 요청 시작")
        
        do {
            let content = try question.buildModelContent()
            
            logger.debug("ModelContent 생성 완료")
            let response = try await model.generateContent([content])
            
            guard let rawText = response.text,
                  rawText.isEmpty == false else {
                logger.error("Firebase LLM 응답이 비어있음")
                return nil
            }
            
            let answer = FirebaseAnswer(rawText)
            let cleanedAnswer = answer.removeCodeBlockFence()
            logger.debug("Firebase LLM 응답 성공: \(cleanedAnswer.content, privacy: .public)")
            
            return cleanedAnswer
        } catch {
            logger.error("Firebase LLM 오류: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    
    public func getEmotionAnalysis(_ question: FirebaseQuestion, character: MentoryCharacter) async -> FirebaseAnalysis? {
        logger.debug("Firebase LLM 요청 시작")
        
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
        
        do {
            let content = try question.buildModelContent()
            logger.debug("ModelContent 생성 완료")
            
            let response = try await newModel.generateContent([content])
            guard let data = response.text?.data(using: .utf8) else {
                return nil
            }
            
            let analysis = try JSONDecoder().decode(FirebaseAnalysis.self, from: data)
            return analysis
        } catch {
            logger.error("\(error)")
            return nil
        }
    }
}


// MARK: extension
fileprivate nonisolated extension FirebaseQuestion {
    func buildModelContent() throws -> ModelContent {
        var parts: [any Part] = []

        // 텍스트 추가
        parts.append(TextPart(content))

        // 이미지 추가 (최대 1개)
        if let imageData = imageData {
            parts.append(InlineDataPart(data: imageData, mimeType: "image/jpeg"))
        }

        // 음성 추가 (최대 1개, wav 포맷)
        if let voiceURL = voiceURL {
            let voiceData = try Data(contentsOf: voiceURL)
            parts.append(InlineDataPart(data: voiceData, mimeType: "audio/wav"))
        }

        return ModelContent(role: "user", parts: parts)
    }
}

