//
//  RecordFormView.swift
//  Mentory
//
//  Created by JAY, 구현모 on 11/17/25.
//
import Foundation
import SwiftUI
import OSLog
import Collections
import AsyncAlgorithms
@preconcurrency import Combine


// MARK: View
struct RecordFormView: View {
    // MARK: core
    nonisolated let logger = Logger(subsystem: "MentoryiOS.RecordForm", category: "Presentation")
    @ObservedObject var recordForm: RecordForm


    // MARK: viewModel
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    
    // 오디오 관련
    @State private var microphone = Microphone.shared
    @State private var showingAudioRecorder = false
    
    
    // MARK: - Body
    var body: some View {
        RecordFormLayout(
            topBar: {
                TopBarLayout(
                    left: {
                        CancelButton(
                            label: "취소",
                            action: recordForm.removeForm
                        )
                    },
                    center: {
                        TodayDate()
                    },
                    right: {
                        SubmitButton(
                            recordForm: recordForm,
                            label: "완료",
                            destination: { mindAnalyzer in
                                MindAnalyzerView(mindAnalyzer)
                            }
                        )
                    }
                )
            },
            main: {
                TitleField(
                    prompt: "제목",
                    text: $recordForm.titleInput
                )
                
                BodyField(
                    prompt: "글쓰기 시작...",
                    text: $recordForm.textInput
                )
                
                self.imagePreviewCard
                self.voicePreviewCard
            },
            bottomBar: {
                self.bottomToolBar
            })
        .task {
            // 기록 시작 시간 설정
            recordForm.startTime = Date()
        }
    }
    
    @ViewBuilder var bottomToolBar: some View {
        Button(action: {
            showingImagePicker = true
        }) {
            Image(systemName: "photo")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(recordForm.imageInput != nil ? .blue : .primary)
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotosPicker(imageData: $recordForm.imageInput)
        }
        
        Button(action: {
            showingCamera = true
        }) {
            Image(systemName: "camera")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(recordForm.imageInput != nil ? .blue : .primary)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(imageData: $recordForm.imageInput, sourceType: .camera)
        }
        
        Button(action: {
            showingAudioRecorder = true
        }) {
            Image(systemName: "waveform")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(recordForm.voiceInput != nil ? .blue : .primary)
        }
        .sheet(isPresented: $showingAudioRecorder) {
            RecordingSheet(
                onComplete: { url in
                    recordForm.voiceInput = url
                    showingAudioRecorder = false
                },
                onCancel: {
                    showingAudioRecorder = false
                }
            )
        }
    }
    
//    private var textInputCard: some View {
//        LiquidGlassCard {
//            ZStack(alignment: .topLeading) {
//                if recordForm.textInput.isEmpty {
//                    Text("글쓰기 시작…")
//                        .foregroundColor(.gray.opacity(0.5))
//                        .padding()
//                        .allowsHitTesting(false)
//                }
//                
//                TextEditor(text: $recordForm.textInput)
//                    .scrollContentBackground(.hidden)
//                    .frame(minHeight: 300)
//                    .padding()
//            }
//        }
//    }
    
    private var imagePreviewCard: some View {
        Group {
            if let imageData = recordForm.imageInput,
               let uiImage = UIImage(data: imageData) {
                
                LiquidGlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(.blue)
                            Text("첨부된 이미지")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                recordForm.imageInput = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding([.horizontal, .top], 16)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }
    private var voicePreviewCard: some View {
        Group {
            if recordForm.voiceInput != nil {
                LiquidGlassCard {
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.blue)
                        
                        Text("음성 녹음 첨부됨")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(timeString(from: microphone.recordingTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button {
                            Task {
                                await microphone.stopListening()
                                recordForm.voiceInput = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


// MARK: Preview
fileprivate struct RecordFormPreview: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard,
           let recordForm = todayBoard.recordForm {
            RecordFormView(
                recordForm: recordForm,
            )
        } else {
            ProgressView("프리뷰 로딩 중입니다.")
                .task {
                    mentoryiOS.setUp()
                    
                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김철수"
                    onboarding.next()
                    
                    let todayBoard = mentoryiOS.todayBoard!
                    todayBoard.setUpForm()
                }
        }
    }
}


#Preview {
    RecordFormPreview()
}


// MARK: Component
fileprivate struct CancelButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ActionButtonLabel(text: self.label,
                              usage: .cancel)
        }
    }
}

fileprivate struct TodayDate: View {
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        Text(formattedDate)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

fileprivate struct SubmitButton<Content: View>: View {
    @ObservedObject var recordForm: RecordForm
    let label: String
    @ViewBuilder let destination: (MindAnalyzer) -> Content
    
    @State var isSubmitEnabled: Bool = false
    @State var showMindAnalyzerView: Bool = false
    @State var showingSubmitAlert: Bool = false

    var body: some View {
        Button {
            showingSubmitAlert = true
        } label: {
            ActionButtonLabel(text: "완료", usage: isSubmitEnabled ? .submitEnabled : .submitDisabled)
        }.disabled(!isSubmitEnabled)
            .alert("일기 제출하기", isPresented: $showingSubmitAlert) {
                Button("취소", role: .cancel) { }
                Button("제출") {
                    Task {
                        recordForm.validateInput()
                        recordForm.submit()
                    }
                }
            } message: {
                Text("일기를 제출하면 수정할 수 없습니다.\n제출하시겠습니까?")
            }
            .keyboardShortcut(.defaultAction)
            .fullScreenCover(isPresented: $showMindAnalyzerView, content: {
                if let mindAnalyzer = recordForm.mindAnalyzer {
                    destination(mindAnalyzer)
                }
            })
            .task {
                let stream = recordForm.$mindAnalyzer.values
                    .map { $0 != nil }
                
                for await isPresented in stream {
                    self.showMindAnalyzerView = isPresented
                }
            }
            .task {
                let titleInputStream = recordForm.$titleInput.values
                let textInputStream = recordForm.$textInput.values
                
                for await (title, text) in zip(titleInputStream, textInputStream) {
                    self.isSubmitEnabled = !title.trimmingCharacters(in: .whitespaces).isEmpty &&
                    !text.trimmingCharacters(in: .whitespaces).isEmpty
                }
            }
    }
}


fileprivate struct TopBarLayout<L:View, C: View, R: View>: View {
    @ViewBuilder let left: () -> L
    @ViewBuilder let center: () -> C
    @ViewBuilder let right: () -> R
    
    var body: some View {
        HStack {
            self.left()
            
            Spacer()
            
            self.center()
            
            Spacer()
            
            self.right()
        }
        .padding(.horizontal)
    }
}

fileprivate struct TitleField: View {
    let prompt: String
    @Binding var text: String
    
    var body: some View {
        LiquidGlassCard {
            TextField(prompt, text: $text)
                .font(.title3)
                .padding()
        }
    }
}

fileprivate struct BodyField: View {
    let prompt: String
    @Binding var text: String
    
    var body: some View {
        LiquidGlassCard {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("글쓰기 시작…")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 300)
                    .padding()
            }
        }
    }
}
