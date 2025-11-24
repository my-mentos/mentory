//
//  EditingName.swift
//  Mentory
//
//  Created by JAY on 11/24/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class EditingName: Sendable, ObservableObject{
    // MARK: core
    nonisolated let logger = Logger(subsystem: "MentoryiOS.RenameSheet", category: "Domain")
    init(owner: SettingBoard, userName: String) {
        self.owner = owner
        self.currentEditingName = userName
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: SettingBoard?
    @Published var currentEditingName: String
    @Published var isSubmitDisabled: Bool = false
    
    
    // MARK: action
    func validate() {
        // capture
        let newName = currentEditingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentName = owner?.owner!.userName ?? ""
        
        // mutate
        if newName.isEmpty || newName == currentName {
            isSubmitDisabled = true
            return
        }
        isSubmitDisabled = false
        
    }

    
    func submit() async {
        // capture
        let newName = currentEditingName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard newName.isEmpty == false else {
            logger.error("입력된 이름이 비어 있어 저장을 건너뜁니다.")
            return
        }
        guard let owner else {
            logger.error("owner가 존재하지 않아 이름을 저장할 수 없습니다.")
            return
        }
        
        // mutate
        let mentoryiOS = owner.owner
        mentoryiOS!.userName = newName
        await mentoryiOS!.saveUserName()
        logger.info("사용자 이름이 \(newName, privacy: .public)로 변경되었습니다.")
    }
    
    func cancel() async {
        self.owner?.editingName = nil
    }
    
    // MARK: value
}
