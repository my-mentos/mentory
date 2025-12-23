//
//  EditingName.swift
//  Mentory
//
//  Created by JAY on 11/24/25.
//
import Foundation
import Combine
import OSLog
import MentoryDBAdapter


// MARK: Object
@MainActor
final class EditingName: Sendable, ObservableObject{
    // MARK: core
    nonisolated let logger = Logger(subsystem: "MentoryiOS.RenameSheet", category: "Domain")
    init(owner: SettingBoard, userName: String) {
        self.owner = owner
        self.nameInput = userName
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: SettingBoard?
    
    @Published var nameInput: String
    @Published var isSubmitDisabled: Bool = true
    
    
    // MARK: action
    func validate() {
        // capture
        let newName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentName = owner?.owner!.userName ?? ""
        
        // process
        let isValid = newName.isEmpty == false && newName != currentName
        
        // mutate
        guard isValid else {
            // 유효하지 않으면 저장 버튼 비활성화
            isSubmitDisabled = true
            return
        }
        isSubmitDisabled = false
    }

    func submit() async {
        // capture
        let newName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard newName.isEmpty == false else {
            logger.error("입력된 이름이 비어 있어 저장을 건너뜁니다.")
            return
        }
        
        let settingBoard = owner!
        let mentoryiOS = settingBoard.owner!
        let mentoryDB = mentoryiOS.mentoryDB
        
        //process
        do {
            try await mentoryDB.setName(newName)
        } catch {
            logger.error("사용자 이름을 변경하는 데 실패했습니다. \(error)")
        }
        
        // mutate
        mentoryiOS.userName = newName
        logger.info("사용자 이름이 \(newName, privacy: .public)로 변경되었습니다.")
    }
    
    func cancel() async {
        self.owner?.editingName = nil
    }
    
    // MARK: value
}
