//
//  Microphone.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import Foundation
import OSLog
import Speech
import AVFoundation


// MARK: Object
@MainActor @Observable
final class Microphone: Sendable {
    // MARK: core
    static let shared = Microphone()
    private init() { }
    
    private nonisolated let logger = Logger(subsystem: "MentoryiOS.Microphone", category: "Presentation")
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var timer: Timer?
    
    
    // MARK: state
    private(set) var isSetUp: Bool = false
    private var engine: AudioEngine? = nil

    private(set) var isRecording: Bool = false
    
    private(set) var audioURL: URL? = nil
    private(set) var recordingTime: TimeInterval = 0
    private(set) var recognizedText: String = ""
    
    
    // MARK: action
    func setUp() async {
        // capture
        guard isSetUp == false else {
            logger.error("이미 Microphone이 setUp되어 있습니다.")
            return
        }
        guard engine == nil else {
            logger.error("이미 Microphone의 AudioEngine이 존재합니다.")
            return
        }
        
        // proces
        let userDevice = UserDevice()
        
        let micGranted = await userDevice.getRecordPermission()
        let speechGranted = await userDevice.getSpeechPermission()
        
        // mutate
        guard micGranted && speechGranted else {
            logger.error("사용자의 녹음 및 음성 인식 권한이 없습니다.")
            return
        }
        
        self.isSetUp = true
        self.engine = AudioEngine()
    }
    
    func startSession() async {
        // capture
        guard isSetUp == true else {
            logger.error("Microphone이 setUp되지 않았습니다.")
            return
        }
        
        // process
        do {
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(.playAndRecord,
                                    mode: .measurement,
                                    options: [.duckOthers, .defaultToSpeaker])
            
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("\(error)")
            return
        }
    }
    
    func recordAndConvertToText() {
        guard !isRecording else { return }
        
        recordingTime = 0
        recognizedText = ""
        
        do {
            try startEngineAndRecognition()
            startTimer()
            isRecording = true
            logger.debug("recordAndConvertToText() 성공")
        } catch {
            logger.error("녹음 시작 실패: \(error.localizedDescription)")
            stop()
        }
    }
    private func startEngineAndRecognition() throws {
        
        recognitionTask?.cancel()
        recognitionTask = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.recognitionRequest = request

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        self.audioURL = fileURL

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        let audioFile = try AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings)
        self.audioFile = audioFile

        logger.debug("inputNode.installTap 설정 시작")

        // ✅ [수정 핵심] nonisolated 함수로 분리하여 호출
        // 메인 액터 컨텍스트에서 벗어나 안전하게 탭을 설치합니다.
        attachAudioTap(to: inputNode, request: request, audioFile: audioFile)

        audioEngine.prepare()
        try audioEngine.start()
        logger.debug("audioEngine.start() 성공")

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                Task { @MainActor in
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }

            if let error = error {
                self.logger.error("recognitionTask 오류: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Helpher
    // ✅ [추가됨] 탭 설치를 위한 Non-isolated 함수
    // 이 함수는 MainActor의 제약을 받지 않으므로, 내부 클로저가 백그라운드에서 실행되어도 안전합니다.
    private nonisolated func attachAudioTap(
        to inputNode: AVAudioInputNode,
        request: SFSpeechAudioBufferRecognitionRequest,
        audioFile: AVAudioFile
    ) {
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            // 이곳은 백그라운드 스레드입니다.
            // nonisolated 함수 내부이므로 컴파일러가 MainActor 체크 코드를 삽입하지 않습니다.
            request.append(buffer)
            
            do {
                try audioFile.write(from: buffer)
            } catch {
                // print("Writing failed: \(error)")
            }
        }
    }
    
    func stop() {
        logger.debug("stop() 호출됨")

        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        audioFile = nil
        timer?.invalidate()
        timer = nil

        Task {
            let session = AVAudioSession.sharedInstance()
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
        }

        isRecording = false
    }
    func startTimer() {
        // capture
        let currentTimer = self.timer
        
        // process
        currentTimer?.invalidate()
        let newTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.recordingTime += 0.1
            }
        }
        
        // mutate
        self.timer = newTimer
    }
    
    
    // MARK: value
    nonisolated struct UserDevice: Sendable {
        func getRecordPermission() async -> Bool {
            await withCheckedContinuation { continuation in
                if #available(iOS 17.0, *) {
                    AVAudioApplication.requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
                } else {
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
        
        func getSpeechPermission() async -> Bool {
            await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }
}
