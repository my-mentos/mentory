//
//  FirebaseLLMFakeAdapter.swift
//  FirebaseLLM
//
//  Created by 김민우 on 12/23/25.
//
import Foundation
import Values


// MARK: Adapter
public nonisolated struct FirebaseLLMFakeAdapter: FirebaseLLMAdapterInterface {
    // MARK: core
    private let answerSamples: [String] = [
        "기록을 분석해보니 지금 집중하고 싶은 감정의 결이 명확하게 드러나고 있어요.",
        "몇몇 문장만으로도 오늘 하루를 압축해서 이해할 수 있었어요.",
        "지금의 마음을 정리하면 다음과 같은 흐름을 확인할 수 있어요."
    ]
    private let positiveKeywords: [String] = [
        "기쁘", "즐겁", "행복", "설레", "감사", "편안", "뿌듯", "재밌", "좋았", "relaxed", "happy", "excited", "grateful", "satisfied"
    ]
    private let negativeKeywords: [String] = [
        "힘들", "지치", "짜증", "화나", "불안", "걱정", "슬프", "우울", "외롭", "답답", "피곤", "lonely", "tired", "anxious", "stressed", "depressed"
    ]
    
    public init() {
        
    }

    // MARK: task
    public func question(_ question: FirebaseQuestion) async -> FirebaseAnswer? {
        let template = answerSamples.randomElement() ?? "기록을 잘 확인했어요."
        guard let snippet = excerpt(from: question, limit: 90) else {
            return FirebaseAnswer(template)
        }

        let response = "\(template)\n\n핵심 메모: \(snippet)"
        return FirebaseAnswer(response)
    }
    
    public func getEmotionAnalysis(_ question: FirebaseQuestion, character: MentoryCharacter) async -> FirebaseAnalysis? {
        let mindType = determineMindType(from: question)
        let sentiment = sentiment(for: mindType)
        let message = empathyMessage(for: sentiment, character: character, question: question)
        let actions = actionKeywords(for: sentiment, character: character)

        return FirebaseAnalysis(mindType: mindType,
                                empathyMessage: message,
                                actionKeywords: actions)
    }

    
    // MARK: value
    private func determineMindType(from question: FirebaseQuestion) -> Emotion {
        let normalized = question.content
            .replacingOccurrences(of: "\n", with: " ")
            .lowercased()
        let positiveScore = score(for: positiveKeywords, in: normalized)
        let negativeScore = score(for: negativeKeywords, in: normalized)
        let balance = positiveScore - negativeScore

        if negativeScore >= 3 && balance <= -2 { return .veryUnpleasant }
        if negativeScore >= 2 && balance <= -1 { return .unPleasant }
        if negativeScore >= 1 && balance < 0 { return .slightlyUnpleasant }

        if positiveScore >= 3 && balance >= 2 { return .veryPleasant }
        if positiveScore >= 2 && balance >= 1 { return .pleasant }
        if positiveScore >= 1 && balance > 0 { return .slightlyPleasant }

        return .neutral
    }

    private func score(for keywords: [String], in normalizedText: String) -> Int {
        keywords.reduce(into: 0) { partialResult, keyword in
            if normalizedText.contains(keyword) {
                partialResult += 1
            }
        }
    }

    private func empathyMessage(for sentiment: Sentiment,
                                character: MentoryCharacter,
                                question: FirebaseQuestion) -> String {
        let highlight = excerpt(from: question) ?? "오늘의 기록"

        switch (character, sentiment) {
        case (.cool, .negative):
            return "기록한 \"\(highlight)\" 문장을 구조적으로 살펴보면 감정을 소모시키는 원인이 반복되고 있어요. 사건-감정-행동을 따로 떼어 정리하면 지금의 혼잡함이 해결 가능한 목록으로 바뀔 수 있습니다."
        case (.cool, .neutral):
            return "\"\(highlight)\" 부분에서는 이미 상황을 관찰하고 있다는 신호가 보여요. 분석이 잘 되어 있으니 지금 필요한 건 우선순위를 재정렬하는 일뿐입니다. 차분함을 활용해서 다음 단계를 정의해보세요."
        case (.cool, .positive):
            return "\"\(highlight)\" 기록은 에너지의 흐름이 안정적이라는 의미예요. 어떤 선택이 잘 작동했는지 짧게 요약해두면 이후에도 같은 조건을 쉽게 재현할 수 있습니다."
        case (.warm, .negative):
            return "방금 적어준 \"\(highlight)\" 이야기를 읽으니 마음이 꽤 무거웠을 것 같아요. 이렇게 털어놓은 것만으로도 큰 용기를 낸 거예요. 잠시 숨을 고르고 나를 위로할 시간을 마련해보면 좋겠어요."
        case (.warm, .neutral):
            return "\"\(highlight)\" 라는 말에는 하루를 차분하게 바라보는 시선이 느껴져요. 감정이 급격히 흔들리지 않았다는 건 마음이 스스로 균형을 찾고 있다는 뜻이에요. 지금의 속도로 편안한 루틴을 이어가도 괜찮아요."
        case (.warm, .positive):
            return "\"\(highlight)\" 부분을 읽으니 나도 덩달아 미소가 지어졌어요. 오늘 느낀 부드러운 에너지가 오래 남을 수 있도록 가볍게라도 흔적을 남겨보자요."
        }
    }

    private func actionKeywords(for sentiment: Sentiment,
                                character: MentoryCharacter) -> [String] {
        switch (character, sentiment) {
        case (.cool, .negative):
            return [
                "가장 에너지를 많이 잡아먹은 사건을 한 문장으로 정리하기",
                "20분 동안 화면에서 벗어나 호흡만 관찰하기",
                "To-Do를 중요도 기준으로 다시 배열하기"
            ]
        case (.cool, .neutral):
            return [
                "오늘 해야 할 일 중 단 하나만 골라 집중 타이머 15분 돌리기",
                "현재 감정을 3줄 보고서 형태로 요약하기",
                "남아 있는 리소스를 수치로 적어보기"
            ]
        case (.cool, .positive):
            return [
                "오늘 성공한 패턴을 데이터처럼 기록하기",
                "다음 목표를 한 문장 KPI로 정의하기",
                "지금의 에너지 수준을 유지하기 위한 체크리스트 만들기"
            ]
        case (.warm, .negative):
            return [
                "지금 감정을 있는 그대로 적어두고 인정해주기",
                "5분간 어깨와 턱 이완하며 깊은 숨 쉬어보기",
                "믿을 만한 사람에게 마음을 한 문장으로 나눠보기"
            ]
        case (.warm, .neutral):
            return [
                "오늘 고마웠던 순간을 사진이나 메모로 남기기",
                "간단한 스트레칭으로 굳어 있는 근육 풀어주기",
                "따뜻한 음료를 준비하면서 호흡 가다듬기"
            ]
        case (.warm, .positive):
            return [
                "스스로에게 짧은 칭찬 메시지 보내기",
                "오늘 좋았던 순간에 어울리는 음악 감상하기",
                "편안한 저녁 루틴을 위해 작은 즐거움 예약하기"
            ]
        }
    }

    private func excerpt(from question: FirebaseQuestion, limit: Int = 70) -> String? {
        let trimmed = question.content
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.isEmpty == false else {
            return nil
        }

        if trimmed.count <= limit {
            return trimmed
        }

        let index = trimmed.index(trimmed.startIndex, offsetBy: limit)
        return String(trimmed[..<index]) + "..."
    }

    private func sentiment(for mindType: Emotion) -> Sentiment {
        switch mindType {
        case .veryUnpleasant, .unPleasant, .slightlyUnpleasant:
            return .negative
        case .neutral:
            return .neutral
        case .slightlyPleasant, .pleasant, .veryPleasant:
            return .positive
        }
    }

    private enum Sentiment {
        case negative
        case neutral
        case positive
    }
}
