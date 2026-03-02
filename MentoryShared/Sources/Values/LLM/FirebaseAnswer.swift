//
//  FirebaseAnswer.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation


// MARK: Value
nonisolated
public struct FirebaseAnswer: Sendable, Hashable {
    // MARK: core
    public let content: String
    
    public init(_ content: String) {
        self.content = content
    }
    
    
    // MARK: operator
    /// 앞뒤의 ``` 코드 펜스를 제거하고 공백을 정리합니다.
    public func removeCodeBlockFence() -> Self {
        let text = self.content
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if result.hasPrefix("```") {
            if let firstNewline = result.range(of: "\n") {
                result = String(result[firstNewline.upperBound...])
            }
            if let closingRange = result.range(of: "```", options: .backwards) {
                result = String(result[..<closingRange.lowerBound])
            }
        }

        let finalResult = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return Self(finalResult)
    }
}
