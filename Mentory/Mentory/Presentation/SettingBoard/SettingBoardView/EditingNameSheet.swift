//
//  EditingNameSheet.swift
//  Mentory
//
//  Created by JAY on 11/24/25.
//

import Foundation
import SwiftUI

// MARK: View
struct EditingNameSheet: View {
    @Environment(\.dismiss) var closeEditingNameSheet
    @ObservedObject var editingName: EditingName
    @FocusState private var isRenameFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("새 이름을 입력하세요", text: $editingName.currentEditingName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isRenameFieldFocused)
                
                Text("변경된 이름은 다음 대화부터 사용돼요.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .navigationTitle("이름 변경")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        Task {
                            await editingName.cancel()
                        }
                        closeEditingNameSheet()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        Task {
                            await editingName.submit()
                        }
                        closeEditingNameSheet()
                    }
                    .disabled(isRenameSaveDisabled)
                }
            }
        }
        .presentationDetents([.height(200)])
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isRenameFieldFocused = true
            }
        }
    }
    
    //TODO: refactoring 가능한지
    private var isRenameSaveDisabled: Bool {
        let trimmed = editingName.currentEditingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentName = editingName.owner?.owner!.userName ?? ""
        return trimmed.isEmpty || trimmed == currentName
    }
}
