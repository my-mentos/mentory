//
//  FirebaseQuestion.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation


// MARK: Value
public nonisolated struct FirebaseQuestion: Sendable, Hashable {
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
