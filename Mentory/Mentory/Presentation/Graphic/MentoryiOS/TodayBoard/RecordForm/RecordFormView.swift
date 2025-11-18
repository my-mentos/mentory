//
//  RecordFormView.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//
import SwiftUI


// MARK: View
struct RecordFormView: View {
    // MARK: model
    @ObservedObject var recordForm: RecordForm
    
    @State private var cachedTextForAnalysis: String = ""
    @State private var isShowingMindAnalyzerView = false
    
    init(_ recordForm: RecordForm) {
        self.recordForm = recordForm
    }
    
    
    // MARK: body
    var body: some View {
        VStack(spacing: 0) {
            recordTopBar
            Divider()
            VStack(spacing: 0) {
                TextField("제목", text: $recordForm.titleInput)
                    .font(.title3)
                    .padding(.horizontal)
                    .padding(.top, 12)
                TextEditor(text: $recordForm.textInput)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .overlay(
                        Group {
                            if recordForm.textInput.isEmpty {
                                Text("글쓰기 시작…")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
                Spacer()
            }
            Divider()
            bottomToolbar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $isShowingMindAnalyzerView) {
            MindAnalyzerView(recordForm.mindAnalyzer!)
        }
    }
    
    private var recordTopBar: some View {
        HStack {
            Image(systemName: "bookmark")
                .font(.title3)
                .padding(.leading)
            Spacer()
            Text("11월 17일 월요일")
                .font(.headline)
            Spacer()
            HStack(spacing: 20) {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                Button(action: {
                    Task {
                        recordForm.validateInput()
                        recordForm.submit()
                        isShowingMindAnalyzerView.toggle()
                    }
                }) {
                    Text("완료")
                        .foregroundColor(.purple)
                }
            }
            .padding(.trailing)
        }
        .padding(.vertical, 8)
    }
    
    private var bottomToolbar: some View {
        HStack {
            Spacer()
            Image(systemName: "photo")
            Spacer()
            Image(systemName: "camera")
            Spacer()
            Image(systemName: "waveform")
            Spacer()
        }
        .padding(.vertical, 10)
        .foregroundColor(.gray)
        .background(Color.gray.opacity(0.12))
    }
    
//    private func handleSubmitTapped() {
//        recordFormModel.validateInput()
//        guard recordFormModel.validationResult == .none else { return }
//        cachedTextForAnalysis = recordFormModel.textInput
//        recordFormModel.submit()
//        recordFormModel.mindAnalyzer = mindAnalyzer
//        recordFormModel.textInput = cachedTextForAnalysis
//        isShowingMindAnalyzerView = true
   // }
    
//    private func resetToEditor() {
//        cachedTextForAnalysis = ""
//        recordFormModel.titleInput = ""
//        recordFormModel.textInput = ""
//        recordFormModel.mindAnalyzer = mindAnalyzer
//        mindAnalyzer.isAnalyzing = false
//        mindAnalyzer.mindType = nil
//        mindAnalyzer.analyzedResult = nil
//    }
}


// MARK: Preview
fileprivate struct RecordFormPreview: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard,
           let recordForm = todayBoard.recordForm {
            RecordFormView(recordForm)
        } else {
            ProgressView("프리뷰 로딩 중입니다.")
                .task {
                    mentoryiOS.setUp()
                    
                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김철수"
                    onboarding.next()
                }
        }
    }
}

#Preview {
    RecordFormPreview()
}
