//
//  MicrophoneView.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import SwiftUI


// MARK: View
struct MicrophoneView: View {
    // MARK: model
    let microphone = Microphone.shared
    
    
    // MARK: body
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header & Timer
            VStack(spacing: 10) {
                Text("STT Tester")
                    .font(.headline)
                    .foregroundStyle(.gray)
                
                Text(formatTime(microphone.recordingTime))
                    .font(.system(size: 50, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText(value: microphone.recordingTime))
                    .animation(.default, value: microphone.recordingTime)
                    .foregroundStyle(microphone.isListening ? .red : .primary)
                
                if microphone.isListening {
                    HStack(spacing: 4) {
                        Circle().fill(.red).frame(width: 8, height: 8)
                        Text("Recording...")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .transition(.opacity)
                }
            }
            .padding(.top, 20)
            
            Divider()
            
            // MARK: - Recognized Text Area
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "waveform.circle")
                    Text("실시간 인식 결과")
                        .font(.subheadline)
                        .bold()
                }
                .foregroundStyle(.secondary)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        Text(microphone.recognizedText.isEmpty ? "대화 내용이 여기에 표시됩니다..." : microphone.recognizedText)
                            .font(.body)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .id("bottom")
                    }
                    .frame(maxHeight: 300)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: microphone.recognizedText) { _, _ in
                        // 텍스트가 추가될 때마다 아래로 스크롤
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // MARK: - File Path (Debug)
            if let url = microphone.audioURL {
                VStack(alignment: .leading) {
                    Text("저장 경로:")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // MARK: - Action Buttons
            VStack(spacing: 12) {
                if !microphone.isSetUp {
                    Button {
                        Task {
                            await microphone.setUp()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("권한 요청 및 설정")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    Button {
                        handleRecordAction()
                    } label: {
                        HStack {
                            Image(systemName: microphone.isListening ? "stop.fill" : "mic.fill")
                            Text(microphone.isListening ? "녹음 중지" : "녹음 시작")
                        }
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(microphone.isListening ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }
    
    
    // MARK: flow
    private func handleRecordAction() {
        if microphone.isListening {
            Task {
                await microphone.stopListening()
                microphone.stopTimer()
            }
        } else {
            Task {
                // 리스닝 시작
                await microphone.startListening()
                microphone.startTimer()
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}



// MARK: Preview
#Preview {
    MicrophoneView()
}
