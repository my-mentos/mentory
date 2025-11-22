//
//  TodayBoard.swift
//  Mentory
//
//  Created by SJS, 구현모 on 11/14/25.
//
import Foundation
import Combine
import Values
import OSLog


// MARK: Object
@MainActor
final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")
    init(owner: MentoryiOS) {
        self.owner = owner
    }


    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryiOS?

    @Published var recordForm: RecordForm? = nil
    @Published var records: [RecordData] = []

    @Published var todayString: String? = nil
    @Published var isFetchedTodayString: Bool = false
    @Published var actionKeyWordItems: [(String, Bool)] = []
    
    // MARK: action
    func fetchTodayString() async {
        // capture
        guard isFetchedTodayString == false else {
            logger.error("오늘의 명언이 이미 fetch되었습니다.")
            return
        }
        let alanLLM = owner!.alanLLM

        // process
        let contentFromAlanLLM: String?
        do {
            // Alan API를 통해 오늘의 명언 또는 속담 요청
            let question = AlanLLM.Question("오늘의 명언이나 속담을 하나만 짧게 알려줘. 명언이나 속담만 답변해줘.")
            let response = try await alanLLM.question(question)

            contentFromAlanLLM = response.content
            logger.debug("오늘의 명언 fetch 성공: \(response.content)")
        } catch {
            logger.error("오늘의 명언 fetch 실패: \(error.localizedDescription)")
            return
        }

        // mutate
        self.todayString = contentFromAlanLLM
        self.isFetchedTodayString = true
    }
    
    func loadTodayRecords() async {
        // capture
        let mentoryDB = owner!.mentoryDB

        // process
        do {
            let todayRecords = try await mentoryDB.fetchToday()
            logger.info("오늘의 레코드 \(todayRecords.count)개 로드 성공")

            // mutate
            self.records = todayRecords
        } catch {
            logger.error("레코드 로드 실패: \(error)")
        }
    }
}
