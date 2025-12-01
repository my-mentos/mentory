//
//  MindAnalyzer.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//
import Foundation
import Values
import Combine
import OSLog
import FirebaseAILogic


// MARK: Object
@MainActor
final class MindAnalyzer: Sendable, ObservableObject {
    // MARK: core
    nonisolated let logger = Logger(subsystem: "MentoryiOS.MindAnalyzer", category: "Domain")
    init(owner: RecordForm) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: RecordForm?

    @Published private(set) var isAnalyzing: Bool = false
    func startAnalyze() { isAnalyzing = true }
    func stopAnalyze() { isAnalyzing = false }
    
    @Published var isAnalyzeFinished: Bool = false
    
    @Published var selectedCharacter: MentoryCharacter? = nil

    @Published var analyzedResult: String? = nil
    @Published var mindType: Emotion? = nil
    
    
    // MARK: action
//    func startAnalyzing() async {
//        // capture
//        guard let textInput = owner?.textInput else {
//            logger.error("TextInput이 비어있습니다.")
//            return
//        }
//
//        guard textInput.isEmpty == false else {
//            logger.error("textInput이 비어있습니다.")
//            return
//        }
//
//        let character = selectedCharacter
//        let recordForm = self.owner!
//        let todayBoard = recordForm.owner!
//        let mentoryiOS = todayBoard.owner!
//        
//        let firebaseLLM = mentoryiOS.firebaseLLM
//
//        
//        // process
//        logger.info("1차 분석 시작")
//        let firstResult: FirstAnalysisResult
//        do {
//            let firstPrompt = """
//            당신은 감정일기 분석을 위한 1차 스크리너입니다.
//            반드시 한국어 입력을 분석해 다음 세 가지 필드를 가진 JSON 형식만 반환해야 합니다.
//            반환 시 마크다운 형식은 사용하지 않습니다.
//
//            {
//                "riskLevel": "low | medium | high",
//                "topic": "텍스트 기반 핵심 주제 한 가지",
//                "mindType": "veryUnpleasant | unPleasant | slightlyUnpleasant | neutral | slightlyPleasant | pleasant | veryPleasant"
//            }
//
//            규칙:
//            1. JSON 이외의 어떤 문장도 출력하지 않는다.
//            2. riskLevel 은 감정적 긴장도·위험 표현·부정성 강도를 보고 판단한다.
//            3. topic 은 일기에서 가장 중심이 되는 주제 한 가지를 명사구로 추출한다. (예: 학업 스트레스, 직장 대인관계, 가족 갈등, 건강 불안, 자기비난 등)
//            4. mindType 은 전체 정서의 쾌·불쾌 정도를 평가한다.
//            5. 판단 근거를 설명하지 않는다. JSON만 출력한다.
//            6. JSON 구조와 키 이름을 절대 변경하지 않는다.
//
//            원본 일기: \(textInput)
//            """
//            let firstQuestion = FirebaseQuestion(firstPrompt)
//            let firstAnswer = try await firebaseLLM.question(firstQuestion)
//
//            // JSON 파싱 (FirebaseLLM에서 코드블록 제거까지 끝낸 상태)
//            guard let jsonData = firstAnswer.content.data(using: .utf8) else {
//                logger.error("1차 분석 결과를 Data로 변환 실패")
//                return
//            }
//
//
//            let decoder = JSONDecoder()
//            firstResult = try decoder.decode(FirstAnalysisResult.self, from: jsonData)
//
//            logger.info("1차 분석 완료 - 위험도: \(firstResult.riskLevel.rawValue), 주제: \(firstResult.topic), mindType: \(firstResult.mindType.rawValue)")
//        } catch {
//            logger.error("1차 분석 실패: \(error)")
//            return
//        }
//
//        // MARK: 2차 분석 - 공감 메시지, 행동 추천 키워드
//        logger.info("2차 분석 시작")
//        let secondResult: SecondAnalysisResult
//        do {
//            let secondPrompt = character.makeSecondAnalysisPrompt(firstResult: firstResult, diaryText: textInput)
//            let secondQuestion = FirebaseQuestion(secondPrompt)
//            let secondAnswer = try await firebaseLLM.question(secondQuestion)
//
//            // JSON 파싱
//            guard let jsonData = secondAnswer.content.data(using: .utf8) else {
//                logger.error("2차 분석 결과를 Data로 변환 실패")
//                return
//            }
//
//
//            let decoder = JSONDecoder()
//            secondResult = try decoder.decode(SecondAnalysisResult.self, from: jsonData)
//
//            logger.info("2차 분석 완료 - 공감 메시지 길이: \(secondResult.empathyMessage.count)자, 추천 키워드 수: \(secondResult.actionKeywords.count)개")
//        } catch {
//            logger.error("2차 분석 실패: \(error)")
//            return
//        }
//
//        
//        // mutate
//        self.firstAnalysisResult = firstResult
//        self.secondAnalysisResult = secondResult
//        
//        self.mindType = firstResult.mindType
//        self.analyzedResult = secondResult.empathyMessage
//        self.isAnalyzeFinished = true
//
//        // TodayBoard의 actionKeyWordItems 업데이트 (체크되지 않은 상태로 초기화, owner: MindAnalyzer -> RecordForm -> TodayBoard)
//        self.owner!.owner!.actionKeyWordItems = secondResult.actionKeywords.map { ($0, false) }
//
//        logger.info("분석 완료")
//    }
    func saveRecord() async {
        // 분석 결과 검증
//        guard let _ = firstAnalysisResult else {
//            logger.error("1차 분석 결과가 없습니다. 저장을 중단합니다.")
//            return
//        }
//        guard let _ = secondAnalysisResult else {
//            logger.error("2차 분석 결과가 없습니다. 저장을 중단합니다.")
//            return
//        }
        guard let analyzedContent = self.analyzedResult,
                !analyzedContent.isEmpty else {
            logger.error("분석된 내용이 비어있습니다. 저장을 중단합니다.")
            return
        }
        

        // capture
        guard let recordForm = owner else {
            logger.error("RecordForm owner가 없습니다.")
            return
        }
        guard let todayBoard = recordForm.owner else {
            logger.error("TodayBoard owner가 없습니다.")
            return
        }
        let mentoryDB = todayBoard.owner!.mentoryDB

        // 행동 추천 데이터 가져오기
        let actionTexts = todayBoard.actionKeyWordItems.map { $0.0 }
        let actionCompletionStatus = todayBoard.actionKeyWordItems.map { $0.1 }

        // MentoryRecord 생성
        let recordData = RecordData(
            id: UUID(),
            createdAt: Date(),
            content: "",
            analyzedResult: analyzedContent,
            emotion: self.mindType!,
            actionTexts: actionTexts,
            actionCompletionStatus: actionCompletionStatus)

        // process
        do {
            try await mentoryDB.saveRecord(recordData)
            
            logger.info("레코드 저장 성공: \(recordData.id)")

            // 저장된 레코드 ID를 TodayBoard에 저장 (체크 상태 업데이트용)
            todayBoard.latestRecordId = recordData.id
        } catch {
            logger.error("레코드 저장 실패: \(error)")
        }
    }
    
    func newAnalyzingExteneded() async {
        // capture
        guard let textInput = owner?.textInput else {
            logger.error("TextInput이 비어있습니다.")
            return
        }

        guard textInput.isEmpty == false else {
            logger.error("textInput이 비어있습니다.")
            return
        }
        
        guard let selectedCharacter else {
            logger.error("캐릭터를 먼저 선택해야 합니다.")
            return
        }

        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        
        let firebaseLLM = mentoryiOS.firebaseLLM
        
        // process
        let question = FirebaseQuestion(textInput)
        
        let analysis: FirebaseAnalysis
        do {
            analysis = try await firebaseLLM.getEmotionAnalysis(question, character: selectedCharacter)
            
        } catch {
            logger.error("\(error)")
            return
        }
        
        
        // mutate
        self.mindType = analysis.mindType
        self.analyzedResult = analysis.empathyMessage
    }
    
    func cancel() {
        // capture
        let recordForm = self.owner
        
        // mutate
        recordForm?.mindAnalyzer = nil
    }
    
    
//    // MARK: value
//    enum CharacterType: Sendable, CaseIterable {
//        case A
//        case B
//        
//        var displayName: String {
//            switch self {
//            case .A: return "냉스 처리스키"
//            case .B: return "알렉산더 지방스"
//            }
//        }
//        
//        var description: String {
//            switch self {
//            case .A: return "냉철한 분석가 초록이가 감정 분석을 도와드릴게요!"
//            case .B: return "감성적인 조력자 지방이가 따뜻하게 답해드릴게요!"
//            }
//        }
//        
//        var imageName: String {
//            switch self {
//            case .A: return "bunsuk"
//            case .B: return "gureum"
//            }
//        }
//    }
}




//        fileprivate func makeSecondAnalysisPrompt(firstResult: MindAnalyzer.FirstAnalysisResult, diaryText: String) -> String {
//            switch self {
//            case .A:
//                // T 스타일
//                return """
//                주제: \(firstResult.topic)
//                위험도: \(firstResult.riskLevel.rawValue)
//                감정 상태: \(firstResult.mindType.rawValue)
//
//                당신은 감정일기 분석을 기반으로 현실적이고 냉철한 관찰을 제공하는 분석 코치입니다.
//                감정 위로보다는 상황을 구조화하고, 핵심 요인과 판단 포인트를 명확히 짚어주는 데 집중합니다.
//                형식적인 말투(입니다, 합니다)는 피하고, 일상 대화처럼 자연스럽고 친근한 존댓말을 사용하세요.
//
//                출력 규칙:
//                1. 반드시 아래 형식의 JSON만 반환한다.
//                2. JSON 외의 어떤 문장도 출력하지 않는다.
//
//                JSON 구조:
//                {
//                    "empathyMessage": "<상황을 객관적으로 정리하고, 사용자의 감정·행동 패턴·주요 요인을 냉정하게 해석해주는 상세 문단>",
//                    "actionKeywords": ["행동1", "행동2", "행동3"]
//                }
//
//                작성 가이드:
//                - 감정적인 위로는 최소화하고, 상황을 논리적으로 해석하는 문장을 중심으로 작성한다.
//                - empathyMessage는 짧을 필요 없다. 3~7문장 정도의 **상세한 관찰**도 허용한다.
//                - 문체는 단정적이되 공격적이지 않고, “지금 어떤 일이 벌어졌는지”를 구조적으로 서술한다.
//                  예: 문제의 원인, 사용자의 반응 패턴, 감정을 높인 요인, 놓치고 있는 포인트 등.
//                - "너는 ~~해야 한다" 같은 명령형은 피하고, “확인할 필요가 있다”, “이렇게 해석할 수 있다”처럼 현실적 제안을 한다.
//                - actionKeywords는 실행 난도가 낮고 짧은 시간 안에 처리 가능한 3개의 구체적 행동만 넣는다.
//                - 상담·의학·진단을 암시하는 표현은 금지한다.
//
//                원본 일기:
//                \(diaryText)
//                """
//
//            case .B:
//                // F 스타일
//                return """
//                주제: \(firstResult.topic)
//                위험도: \(firstResult.riskLevel.rawValue)
//                감정 상태: \(firstResult.mindType.rawValue)
//
//                당신은 감정일기 분석을 기반으로 따뜻하고 공감적인 메시지를 제공하는 감정 코치입니다.
//                단순 위로가 아니라, 사용자가 느낀 감정과 그 배경을 부드럽고 자세하게 정리해주는 것이 목표입니다.
//                형식적인 말투(입니다, 합니다)는 피하고, 일상 대화처럼 자연스럽고 친근한 존댓말을 사용하세요.
//
//                출력 규칙:
//                1. 반드시 아래 형식의 JSON만 반환한다.
//                2. JSON 외의 어떤 문장도 출력하지 않는다.
//
//                JSON 구조:
//                {
//                    "empathyMessage": "<따뜻한 톤으로 감정과 상황을 해석해주는 상세 문단>",
//                    "actionKeywords": ["행동1", "행동2", "행동3"]
//                }
//
//                작성 가이드:
//                - empathyMessage는 3~7문장 정도의 **상세한 감정 해석과 공감**, 그리고 부드럽고 현실적인 정서적 지지를 포함한다.
//                - 사용자가 느낀 감정의 뿌리·상황적 요인·스트레스가 높아진 이유 등을 따뜻한 시각으로 풀어준다.
//                - 사용자의 감정을 정당화하고, ‘이런 감정이 드는 건 충분히 그럴 수 있다’는 메시지를 자연스럽게 담는다.
//                - 과도한 칭찬/감정 과장/치료적 조언은 금지.
//                - actionKeywords는 부담 없이 바로 해볼 수 있는 짧고 부드러운 3개의 자기돌봄 행동으로 구성한다.
//                  예: 짧은 산책, 몸 풀어주기, 좋아하는 음료 마시기, 5분 정리 등.
//                - 문장은 부드럽고 친절한 톤을 유지한다. “당신은…”보다는 “지금 이렇게 느낄 수 있어요”처럼 정서적 수용을 중심으로.
//                - 상담·의학·진단 표현은 금지한다.
//
//                원본 일기:
//                \(diaryText)
//                """
//            }
//        }
