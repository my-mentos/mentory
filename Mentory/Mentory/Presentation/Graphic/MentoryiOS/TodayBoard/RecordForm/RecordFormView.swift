//
//  RecordFormView.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//

import SwiftUI

struct RecordFormView: View {
    // Model -> 비즈니스 로직
    @ObservedObject var recordFormModel: RecordForm
    
    // ViewModel -> 화면의 열고 닫고
    @State private var cachedTextForAnalysis: String = ""
    @State private var isShowingMindAnalyzerView = false
    
    var body: some View {
        VStack(spacing: 0) {
            recordTopBar
            Divider()
            VStack(spacing: 0) {
                TextField("제목", text: $recordFormModel.titleInput)
                    .font(.title3)
                    .padding(.horizontal)
                    .padding(.top, 12)
                TextEditor(text: $recordFormModel.textInput)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .overlay(
                        Group {
                            if recordFormModel.textInput.isEmpty {
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
            MindAnalyzerView(mindAnalyzer: recordFormModel.mindAnalyzer!)
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
                        recordFormModel.validateInput()
                        recordFormModel.submit()
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

#Preview {
    let mentoryiOS = MentoryiOS()
    let todayBoard = TodayBoard(owner: mentoryiOS)
    return RecordFormView(recordFormModel: todayBoard.recordForm!)
}
