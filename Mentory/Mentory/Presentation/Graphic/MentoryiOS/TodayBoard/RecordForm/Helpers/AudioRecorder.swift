//
//  AudioRecorder.swift
//  Mentory
//
//  Created by 구현모 on 11/18/25.
//

import SwiftUI
import Combine
import AVFoundation
import OSLog

@MainActor
class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var audioURL: URL?
    @Published var recordingTime: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.AudioRecorderManager", category: "Graphic")

    override init() {
        super.init()
        logger.debug("AudioRecorderManager init() 완료")
        setupAudioSession()
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func startRecording() {
        // 녹음 파일 경로 생성
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            isRecording = true
            recordingTime = 0

            // 타이머 시작
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    self.recordingTime = self.audioRecorder?.currentTime ?? 0
                }
            }
        } catch {
            print("Could not start recording: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false

        if let url = audioRecorder?.url {
            audioURL = url
        }
    }

    func deleteRecording() {
        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
            audioURL = nil
        }
        recordingTime = 0
    }

    // AVAudioRecorderDelegate
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            Task { @MainActor in
                self.isRecording = false
            }
        }
    }
}

// MARK: - 녹음 시트
struct RecordingSheet: View {
    @ObservedObject var audioManager: AudioRecorderManager
    var onComplete: (URL) -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("음성 녹음")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)

            // 녹음 시간 표시
            Text(timeString(from: audioManager.recordingTime))
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(audioManager.isRecording ? .red : .primary)

            // 녹음 파형 애니메이션 (시각적 효과)
            if audioManager.isRecording {
                WaveformView()
                    .frame(height: 80)
                    .padding(.horizontal, 40)
            } else {
                Spacer()
                    .frame(height: 80)
            }

            Spacer()

            // 녹음 컨트롤
            HStack(spacing: 40) {
                // 취소 버튼
                Button(action: {
                    if audioManager.isRecording {
                        audioManager.stopRecording()
                    }
                    audioManager.deleteRecording()
                    onCancel()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .clipShape(Circle())
                }

                // 녹음/정지 버튼
                Button(action: {
                    if audioManager.isRecording {
                        audioManager.stopRecording()
                    } else {
                        audioManager.startRecording()
                    }
                }) {
                    Image(systemName: audioManager.isRecording ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(audioManager.isRecording ? Color.red : Color.blue)
                        .clipShape(Circle())
                }

                // 완료 버튼
                Button(action: {
                    if audioManager.isRecording {
                        audioManager.stopRecording()
                    }
                    if let url = audioManager.audioURL {
                        onComplete(url)
                    }
                }) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(audioManager.audioURL != nil ? Color.green : Color.gray)
                        .clipShape(Circle())
                }
                .disabled(audioManager.audioURL == nil)
            }
            .padding(.bottom, 50)
        }
        .onDisappear {
            if audioManager.isRecording {
                audioManager.stopRecording()
            }
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - 파형 애니메이션 뷰
struct WaveformView: View {
    @State private var animationValues: [CGFloat] = Array(repeating: 0.3, count: 20)

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red)
                    .frame(width: 3)
                    .frame(height: CGFloat.random(in: 10...60) * animationValues[index])
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 0.3...0.8))
                            .repeatForever(autoreverses: true),
                        value: animationValues[index]
                    )
            }
        }
        .onAppear {
            for index in 0..<20 {
                animationValues[index] = CGFloat.random(in: 0.3...1.0)
            }
        }
    }
}
