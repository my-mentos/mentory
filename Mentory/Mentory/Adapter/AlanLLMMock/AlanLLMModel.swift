////
////  AlanLLMModel.swift
////  Mentory
////
////  Created by 김민우 on 11/18/25.
////
//import Foundation
//import Collections
//import Values
//import OSLog
//
//
//// MARK: Object
//@MainActor
//final class AlanLLMModel: Sendable {
//    // MARK: core
//    nonisolated init() { }
//    
//    
//    // MARK: state
//    nonisolated let logger = Logger(subsystem: "AlanLLM.AlanLLMMock", category: "Domain")
//
//    /// 1차 분석용 샘플 JSON (FirstAnalysisResult 디코딩 가능)
//    nonisolated private let firstAnalysisSamples: [String] = [
//        #"{"riskLevel":"low","topic":"학업 스트레스","mindType":"slightlyUnpleasant"}"#,
//        #"{"riskLevel":"medium","topic":"대인관계 피로","mindType":"unPleasant"}"#,
//        #"{"riskLevel":"high","topic":"자기비난","mindType":"veryUnpleasant"}"#
//    ]
//
//    /// 2차 분석용 샘플 JSON (SecondAnalysisResult 디코딩 가능)
//    nonisolated private let secondAnalysisSamples: [String] = [
//        #"{"empathyMessage":"지금 상황을 이렇게 정리해볼 수 있을 것 같아요. 오늘 하루 동안 쌓여 있던 생각과 감정이 한꺼번에 터지면서 많이 지치고 힘들었을 수 있어요. 괜찮은 척 버티느라 스스로를 돌볼 여유도 별로 없었을 것 같아요.","actionKeywords":["짧은 산책하기","오늘 가장 힘들었던 순간 한 줄로 적기","따뜻한 음료 마시면서 숨 고르기"]}"#,
//        #"{"empathyMessage":"요즘 계속 긴장 상태로 버티고 있어서 마음이 쉴 틈이 거의 없었던 것 같아요. 잘 해내야 한다는 부담이 크다 보니, 작은 실수에도 스스로를 심하게 몰아붙였을 수 있어요. 이렇게 털어놓은 것만으로도 이미 큰 시작이에요.","actionKeywords":["오늘 했던 일 중 잘한 것 1가지 찾기","휴대폰 내려두고 5분간 눈 감고 쉬기","내일 꼭 해야 할 일 1개만 적어두기"]}"#,
//        #"{"empathyMessage":"사소해 보이는 일들이 겹치면서 마음속에서는 꽤 큰 파도가 계속 치고 있었을 것 같아요. 주변 사람들에게 설명하기도 애매해서 혼자서 더 오래 끌어안고 있었을지도 몰라요. 그만큼 이 감정은 가볍지 않았다는 의미예요.","actionKeywords":["지금 느끼는 감정을 한 단어로 적어보기","잠깐 자리에서 일어나 몸 한번 쭉 늘려주기","오늘 나를 조금 편하게 해줬던 순간 떠올려보기"]}"#
//    ]
//
//    /// 기존 프로퍼티를 유지하고 싶다면, 두 샘플 배열을 합쳐서 Answer 배열로 노출
//    nonisolated var answers: [AlanLLM.Answer] {
//        (firstAnalysisSamples + secondAnalysisSamples).map {
//            .init(action: .init(name: "speak", speak: $0), content: $0)
//        }
//    }
//    var answerBox: [AlanQuestion.ID: AlanLLM.Answer] = [:]
//    var questionQueue: Deque<AlanQuestion> = []
//    
//    
//    // MARK: action
//    func processQuestions() {
//        // capture
//        guard questionQueue.isEmpty == false else {
//            logger.error("questionQueue가 비어 있습니다.")
//            return
//        }
//
//        // mutate
//        while questionQueue.isEmpty == false {
//            let question = questionQueue.removeFirst()
//
//            // AlanLLM.Question 이 `content` 프로퍼티로 프롬프트를 가지고 있다고 가정
//            // 1차 분석 프롬프트 문구를 포함하면 1차 샘플, 아니면 2차 샘플을 사용
//            let prompt = question.content
//
//            let content: String
//            if prompt.contains("감정일기 분석을 위한 1차 스크리너") {
//                // 1차 분석용 JSON
//                content = firstAnalysisSamples.randomElement()!
//            } else {
//                // 2차 분석용 JSON
//                content = secondAnalysisSamples.randomElement()!
//            }
//
//            let answer = AlanLLM.Answer(
//                action: .init(name: "speak", speak: content),
//                content: content
//            )
//
//            answerBox[question.id] = answer
//        }
//    }
//    
//    
//    // MARK: value
//    
//}
