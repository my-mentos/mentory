//
//  AudioEngine.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import Foundation
import OSLog
import AVFoundation
import Speech


// MARK: Object
actor AudioEngine {
    // MARK: core
    static let shared = AudioEngine()
    
    
    // MARK: state
    private nonisolated let logger = Logger(subsystem: "MentoryiOS.AudioEngine", category: "Presentation")
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private let audioEngine = AVAudioEngine()
    
    
    private var isEngineSetUp: Bool = false
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var isAudioSetup: Bool = false
    private(set) var audioURL: URL? = nil
    private var audioFile: AVAudioFile? = nil
    
    private var isAudioProcessing: Bool = false
    private var recognitionTask: SFSpeechRecognitionTask?
    private var sttHandler: STTTextHandler? = nil
    internal func setHandler(_ handler: @escaping STTTextHandler) {
        self.sttHandler = handler
    }
    
    
    // MARK: action
    func setUpEngine() {
        // capture
        guard isEngineSetUp == false else {
            logger.error("이미 세션이 실행 중입니다.")
            return
        }
        
        // process
        let request: SFSpeechAudioBufferRecognitionRequest
        do {
            // 시스템 레벨 오디오 세션 준비
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(.playAndRecord,
                                    mode: .measurement,
                                    options: [.duckOthers, .defaultToSpeaker])
            
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            // STT 요청 객체 준비
            recognitionTask?.cancel()
            recognitionTask = nil

            let tempRequest = SFSpeechAudioBufferRecognitionRequest()
            tempRequest.shouldReportPartialResults = true
            
            request = tempRequest
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        logger.debug("AudioEngine 세션 시작")
        self.isEngineSetUp = true
        self.recognitionRequest = request
    }
    func setUpAudioFile() async {
        // capture
        guard isAudioSetup == false  else {
            logger.error("이미 AudioFile이 설정되어 있습니다.")
            return
        }
        guard isEngineSetUp == true else {
            logger.error("AudioEngine.setUpAudioFile() 실패: setUpEngine()이 먼저 호출되지 않았습니다.")
            return
        }
        
        // process
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        
        
        let avAudioFile: AVAudioFile
        do {
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            avAudioFile = try AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings)
        } catch {
            logger.error("AVAudioFile 생성 실패: \(error.localizedDescription)")
            return
        }

        // mutate
        self.audioURL = fileURL
        self.audioFile = avAudioFile
        self.isAudioSetup = true
    }
    
    func startAudioProcessing() {
        // capture
        guard isAudioProcessing == false else {
            logger.error("이미 AudioProcessing이 진행 중입니다.")
            return
        }
        guard let audioFile = self.audioFile else {
            logger.error("AudioEngine.startAudioProcessing() 실패: audioFile이 nil입니다. setUpAudioFile()이 성공적으로 실행되었는지 확인하세요.")
            return
        }
        guard let request = self.recognitionRequest else {
            logger.error("AudioEngine.startAudioProcessing() 실패: recognitionRequest가 nil입니다. setUpEngine()이 먼저 호출되었는지 확인하세요.")
            return
        }
        let handler = self.sttHandler
        let inputNode = self.audioEngine.inputNode
        
        
        // process
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            request.append(buffer)
            
            do {
                try audioFile.write(from: buffer)
            } catch {
                self?.logger.error("\(error)")
                return
            }
        }
        
        do {
            // 엔진이 사용할 리소스를 미리 할당해서 start() 호출 시 지연, 끊김이 덜 발생하게 준비
            audioEngine.prepare()
            
            // OS의 오디오 하드웨어와 실제로 연결을 시작
            try audioEngine.start()
            
            logger.debug("Audio processing이 시작되었습니다.")
        } catch {
            logger.error("\(error)")
        }
        
        let task = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                let text = result.bestTranscription.formattedString
                
                Task {
                    handler?(text)
                }
            }
            
            if let error = error {
                Logger().error("recognitionTask 오류: \(error.localizedDescription)")
            }
        }
        
        // mutate
        self.recognitionTask = task
        self.isAudioProcessing = true
    }
    func stopAudioProcessing() {
        // capture
        guard isAudioProcessing == true else {
            logger.error("AudioEngine.stopAudioProcessing() 호출됨: 현재 AudioProcessing이 진행 중이 아닙니다.")
            return
        }
        
        // process
        do {
            // 더 이상 오디오 안 들어간다고 알림
            recognitionRequest?.endAudio()
            
            // 진행 중인 인식 작업 취소
            recognitionTask?.cancel()
            
            // 오디오 엔진 정리
            if audioEngine.isRunning {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
            }
            
            // 오디오세션 비활성화
            let session = AVAudioSession.sharedInstance()
            try session.setActive(false, options: .notifyOthersOnDeactivation)

        } catch {
            logger.error("\(error.localizedDescription)")
        }
        
        // mutate
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.isAudioProcessing = false
        self.isEngineSetUp = false
        
        self.audioFile = nil
        self.isAudioSetup = false
    }
    
    
    // MARK: value
    typealias STTTextHandler = @Sendable (String) -> Void
}
