//
//  FirebaseLLMAdapterInterface.swift
//  FirebaseLLM
//
//  Created by 김민우 on 12/23/25.
//
import Values


// MARK: Interface
public protocol FirebaseLLMAdapterInterface: Sendable {
    func question(_ question: FirebaseQuestion) async -> FirebaseAnswer?
    func getEmotionAnalysis(_ question: FirebaseQuestion, character: MentoryCharacter) async -> FirebaseAnalysis?
}
