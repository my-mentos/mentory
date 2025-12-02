//
//  MentorMessage.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import Combine
import Values


// MARK: Object
@MainActor
final class MentorMessage: Sendable, ObservableObject {
    // MARK: core
    init(owner: TodayBoard,
         content: String,
         character: MentoryCharacter) {
        self.owner = owner
        self.content = content
        self.character = character
    }
    
    
    // MARK: state
    weak var owner: TodayBoard?
    
    nonisolated let character: MentoryCharacter
    
    @Published private(set) var content: String
    
    
    
    // MARK: action
    func updateContent() async {
        fatalError()
    }
    
    
    // MARK: value
}
