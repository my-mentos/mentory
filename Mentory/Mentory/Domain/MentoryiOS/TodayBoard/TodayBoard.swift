//
//  TodayBoard.swift
//  Mentory
//
//  Created by SJS, 구현모 on 11/14/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")
    weak var owner: MentoryiOS?

    var recordForm: RecordForm? = nil
    @Published var records: [RecordForm.Record] = []


    @Published var todayString: String? = nil

    // MARK: action
    func fetchTodayString() async {
        do {
            // Alan API를 통해 오늘의 명언 또는 속담 요청
            let response = try await AlanAPIService.shared.question(
                content: "오늘의 명언이나 속담을 하나만 짧게 알려줘. 명언이나 속담만 답변해줘."
            )

            self.todayString = response.content
            logger.info("오늘의 명언 fetch 성공: \(response.content)")

        } catch {
            logger.error("오늘의 명언 fetch 실패: \(error.localizedDescription)")

            // Fallback: API 호출 실패시 기본 명언 사용
            let fallbackQuotes = [
                "먼저핀꽃은 먼저진다 남보다 먼저 공을 세우려고 조급히 서둘것이 아니다",
                "삶이 있는 한 희망은 있다",
                "피할수 없으면 즐겨라"
            ]

            if let randomQuote = fallbackQuotes.randomElement() {
                self.todayString = randomQuote
                logger.info("Fallback 명언 사용: \(randomQuote)")
            }
        }
    }


    // MARK: value
    
}
