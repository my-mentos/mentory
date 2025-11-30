//
//  EditingNameSheet.swift
//  Mentory
//
//  Created by JAY on 11/24/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: View
struct EditingNameSheet: View {
    // MARK: model
    @Environment(\.dismiss) var closeEditingNameSheet
    @ObservedObject var editingName: EditingName
    @FocusState private var nameTextFieldFocused: Bool
    // MARK: body
    var body: some View {
        NavigationStack {
            //이름입력 + 설명
            content
                .padding()
                .navigationTitle("이름 변경")
                .toolbar {
                    // 취소저장버튼
                    cancelToolbarButton
                    submitToolbarButton
                }
        }
        .presentationDetents([.height(200)])
        .onAppear(perform: focusNameTextField)
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 16) {
            nameTextField
            descriptionText
        }
    }
    
    @ViewBuilder
    private var nameTextField: some View {
        TextField("새 이름을 입력하세요", text: $editingName.nameInput)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .focused($nameTextFieldFocused)
            .task {
                let stream = editingName.$nameInput.values
                for await _ in stream {
                    editingName.validate()
                }
            }
    }
    
    @ViewBuilder
    private var descriptionText: some View {
        Text("변경된 이름은 다음 대화부터 사용돼요.")
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ToolbarContentBuilder
    private var cancelToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("취소") {
                Task { await editingName.cancel() }
                closeEditingNameSheet()
            }
        }
    }
    
    @ToolbarContentBuilder
    private var submitToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("저장") {
                Task { await editingName.submit() }
                closeEditingNameSheet()
            }
            .disabled(editingName.isSubmitDisabled)
        }
    }
    
    private func focusNameTextField() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            nameTextFieldFocused = true
        }
    }
}
