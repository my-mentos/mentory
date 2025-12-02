//
//  RecordContainerView.swift
//  Mentory
//
//  Created by JAY on 12/2/25.
//

import Foundation
import SwiftUI
import Combine


// MARK: View
struct RecordContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath = NavigationPath()
    @State private var isSubmitEnabled = false
    @ObservedObject var recordForm: RecordForm
    
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            RecordFormView(recordForm: recordForm)
                .navigationDestination(for: String.self) { value in
                    if value == "MindAnalyzerView" {
                        MindAnalyzerView(recordForm.mindAnalyzer!)
                    }
                }
                .toolbar {
                    // MARK: 취소 버튼
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if navigationPath.isEmpty {
                                // 현재 화면 = RecordFormView
                                dismiss()                   // RecordContainerView 종료
                            } else {
                                // 현재 화면 = MindAnalyzer
                                navigationPath.removeLast() // MindAnalyzerView → RecordFormView
                            }
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    // MARK: 완료 버튼 (RecordFormView에서만 보임)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if navigationPath.isEmpty {
                            // 현재 화면 = RecordFormView
                            Button {
                                Task {
                                    recordForm.validateInput()
                                    if recordForm.canProceed {
                                        await recordForm.submit()
                                        if recordForm.mindAnalyzer != nil {
                                            navigationPath.append("MindAnalyzerView")
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "checkmark")
                            }
                            .disabled(!isSubmitEnabled)
                        }
                    }
                }
            // MARK: 입력 변경 감지 → validateInput() 호출
                .onReceive(recordForm.$titleInput) { _ in
                    recordForm.validateInput()
                }
                .onReceive(recordForm.$textInput) { _ in
                    recordForm.validateInput()
                }
            
            // MARK: canProceed 변경 감지 → 완료버튼 활성화 반영
                .task {
                    for await canProceed in recordForm.$canProceed.values {
                        self.isSubmitEnabled = canProceed
                    }
                }
        }
    }
}
