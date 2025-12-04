//
//  FirebaseQuestion.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation
import FirebaseAI


// MARK: Value
nonisolated
public struct FirebaseQuestion: Sendable, Hashable {
    public let content: String
    public let imageData: Data?
    public let voiceURL: URL?

    public init(_ content: String,
                imageData: Data? = nil,
                voiceURL: URL? = nil) {
        self.content = content
        self.imageData = imageData
        self.voiceURL = voiceURL
    }
}


// MARK: - Conversion
public extension FirebaseQuestion {
    func toModelContent() throws -> ModelContent {
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
