//
//  SpeechToTextManager.swift
//  Mentory
//
//  Created by JAY on 11/20/25.
//

import Foundation
import Combine
import Speech
import OSLog
import AVFoundation


// MARK: Object
@MainActor
class SpeechToTextManager: NSObject, ObservableObject {
    // MARK: core
    
    
    // MARK: state
    nonisolated let logger = Logger(subsystem: "MentoryiOS.SpeechToTextManager", category: "Domain")
    @Published var recognizedText: String = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    // MARK: action
    func startRecognizing() {
        recognizedText = ""
        logger.debug("startRecognizing() 호출됨")
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus != .authorized {
                self.logger.error("음성 인식 권한 거부됨")
                return
            }
            
            DispatchQueue.main.async {
                self.logger.debug("음성 인식 권한 허용됨 → startRecognitionStream() 호출")
                self.startRecognitionStream()
            }
        }
    }
    
    
    private func startRecognitionStream() {
        #if targetEnvironment(simulator)
        logger.debug("⚠️startRecognitionStream() 호출됨 — 시뮬레이터에서는 audioEngine을 사용할 수 없습니다.")
        return
        #endif
        
        logger.debug("startRecognitionStream() 시작됨. 이전 recognitionTask 정리 중…")
        
        task?.cancel()
        task = nil
        
        // Audio Session 설정
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            logger.debug("AudioSession 설정 완료")
        } catch {
            logger.error("AudioSession 설정 실패: \(error.localizedDescription)")
            return
        }
        
        // Speech Request 초기화
        request = SFSpeechAudioBufferRecognitionRequest()
        
        guard let request = request else {
            logger.error("request 생성 실패")
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        logger.debug("inputNode.installTap 시작")
        
        inputNode.removeTap(onBus: 0) // 혹시 모를 중복 tap 제거
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        // AudioEngine 시작
        audioEngine.prepare()
        do {
            try audioEngine.start()
            logger.debug("audioEngine.start() 성공 — 녹음 시작됨")
        } catch {
            logger.error("audioEngine.start() 실패: \(error.localizedDescription)")
            return
        }
        
        // Speech RecognitionTask 생성
        logger.debug("recognitionTask 생성")
        task = speechRecognizer?.recognitionTask(with: request) { result, error in
            
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                    self.logger.debug("recognitionTask 성공")
                }
            }
            
            if let error = error {
                self.logger.error("recognitionTask 오류: \(error.localizedDescription)")
                self.stopRecognizing()
            }
        }
    }
    
    func stopRecognizing() {
        logger.debug("stopRecognizing() 호출됨 — 녹음 및 인식 중지")
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        request?.endAudio()
        request = nil
        
        task?.cancel()
        task = nil
        
        logger.debug("stopRecognizing() 완료")
    }
}
