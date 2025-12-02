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
import Values


// MARK: View
struct RecordFormView: View {
    // MARK: core
    nonisolated let logger = Logger(subsystem: "MentoryiOS.RecordForm", category: "Presentation")
    @ObservedObject var recordForm: RecordForm
    
    
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
                        TodayDate(targetDate: recordForm.targetDate)
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
                
                ImagePreviewCard(
                    model: recordForm
                )
                
                VoicePreviewCard(
                    model: recordForm
                )
            },
            bottomBar: {
                ImageButton(
                    model: recordForm
                )
                
                CameraButton(
                    model: recordForm
                )
                
                AudioButton(
                    model: recordForm
                )
            })
        .task {
            // 기록 시작 시간 설정
            recordForm.startTime = Date()
        }
    }
}


// MARK: Preview
fileprivate struct RecordFormPreview: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard,
           let recordForm = todayBoard.recordForms.first {
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
                    await todayBoard.setupRecordForms()
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
    let targetDate: MentoryDate

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: targetDate.rawValue)
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
                        await recordForm.submit()
                    }
                }
            } message: {
                Text("일기를 제출하면 수정할 수 없습니다.\n제출하시겠습니까?")
            }
            .keyboardShortcut(.defaultAction)
        
            .navigationDestination(isPresented: $showMindAnalyzerView, destination: {
                if let mindAnalyzer = recordForm.mindAnalyzer {
                    destination(mindAnalyzer)
                }
            }
            )
        
            .task {
                let stream = recordForm.$mindAnalyzer.values
                    .map { $0 != nil }
                    .dropFirst()
                
                for await isPresented in stream {
                    self.showMindAnalyzerView = isPresented
                }
            }
        
        
            .onReceive(recordForm.$textInput, perform: { _ in
                recordForm.validateInput()
            })
            .onReceive(recordForm.$titleInput, perform: { _ in
                recordForm.validateInput()
            })
            .task {
                let canProceedStream = recordForm.$canProceed.values
                
                for await canProceed in canProceedStream {
                    self.isSubmitEnabled = canProceed
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
                        .padding(.leading, 21)
                        .padding(.top, 24)
                        .padding(.trailing, 21)
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


fileprivate struct ImageButton: View {
    @ObservedObject var model: RecordForm
    
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        Button(action: {
            showImagePicker = true
        }) {
            Image(systemName: "photo")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(model.imageInput != nil ? .blue : .primary)
        }
        .sheet(isPresented: $showImagePicker) {
            PhotosPicker(imageData: $model.imageInput)
        }
    }
}

fileprivate struct CameraButton: View {
    @ObservedObject var model: RecordForm
    
    @State private var showCameraSheet: Bool = false
    
    var body: some View {
        Button(action: {
            showCameraSheet = true
        }) {
            Image(systemName: "camera")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(model.imageInput != nil ? .blue : .primary)
        }
        .sheet(isPresented: $showCameraSheet) {
            ImagePicker(imageData: $model.imageInput, sourceType: .camera)
        }
    }
}

fileprivate struct AudioButton: View {
    @ObservedObject var model: RecordForm
    @State private var showingAudioRecorder = false
    
    var body: some View {
        Button(action: {
            showingAudioRecorder = true
        }) {
            Image(systemName: "waveform")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(model.voiceInput != nil ? .blue : .primary)
        }
        .sheet(isPresented: $showingAudioRecorder) {
            RecordingSheet(
                onComplete: { url in
                    model.voiceInput = url
                    showingAudioRecorder = false
                },
                onCancel: {
                    showingAudioRecorder = false
                }
            )
        }
    }
}

fileprivate struct ImagePreviewCard: View {
    @ObservedObject var model: RecordForm
    
    var body: some View {
        Group {
            if let imageData = model.imageInput,
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
                                model.imageInput = nil
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
}

fileprivate struct VoicePreviewCard: View {
    @ObservedObject var model: RecordForm
    
    @State private var microphone = Microphone.shared
    
    var body: some View {
        Group {
            if model.voiceInput != nil {
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
                                model.voiceInput = nil
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
