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
    private var timer: Timer?
    
    
    // MARK: state
    private(set) var isSetUp: Bool = false
    private var engine: AudioEngine? = nil
    
    private(set) var audioURL: URL? = nil
    private(set) var recordingTime: TimeInterval = 0
    private(set) var recognizedText: String = ""
    
    private(set) var isListening: Bool = false
    
    
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
    
    func startListening() async {
        // capture
        guard isListening == false else {
            logger.error("이미 음성 인식 중입니다.")
            return
        }
        guard let engine else {
            logger.error("AudioEngine이 현재 존재하지 않습니다.")
            return
        }
        
        // process
        await engine.setHandler { [weak self] speechText in
            Task { @MainActor in
                self?.recognizedText = speechText
            }
        }
        
        await engine.setUpEngine()
        await engine.setUpAudioFile()
        
        await engine.startAudioProcessing()
        
        // mutate
        self.isListening = true
    }
    func stopListening() async {
        // capture
        logger.debug("현재 Microphone.isListening: \(self.isListening)")
        
        guard let engine else {
            logger.error("AudioEngine이 현재 존재하지 않습니다.")
            return
        }
        
        // process
        await engine.stopAudioProcessing()
        
        let latestURL = await engine.audioURL
        
        // mutate
        self.audioURL = latestURL
        self.isListening = false
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
        newTimer.fire()
        self.timer = newTimer
    }
    func stopTimer() {
        // process
        timer?.invalidate()
        
        // mutate
        self.timer = nil
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
