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
    @Published var latestRecordId: UUID? = nil // 가장 최근 저장된 레코드 ID (행동 추천 업데이트용)
    
    
    // MARK: action
    func getIndicator() -> String {
        // 모든 레코드에서 행동 추천 수 합산
        let totalActions = records.reduce(0) { $0 + $1.actionTexts.count }
        let completedActions = records.reduce(0) { sum, record in
            sum + record.actionCompletionStatus.filter { $0 }.count
        }
        return "\(completedActions)/\(totalActions)"
    }

    func getProgress() -> Double {
        // 모든 레코드에서 행동 완료율 계산
        let totalActions = records.reduce(0) { $0 + $1.actionTexts.count }
        guard totalActions > 0 else { return 0 }
        let completedActions = records.reduce(0) { sum, record in
            sum + record.actionCompletionStatus.filter { $0 }.count
        }
        return Double(completedActions) / Double(totalActions)
    }


    func setUpForm() {
        logger.debug("TodayBoard.setUp 호출")
        
        // capture
        guard self.recordForm == nil else {
            logger.error("이미 TodayBoard에 RecordForm이 존재합니다.")
            return
        }
        
        // mutate
        self.recordForm = RecordForm(owner: self)
    }
    
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

            // 가장 최근 레코드의 행동 추천을 actionKeyWordItems에 로드
            if let lastRecord = todayRecords.max(by: { $0.createdAt < $1.createdAt }) {
                self.actionKeyWordItems = zip(lastRecord.actionTexts, lastRecord.actionCompletionStatus).map { ($0, $1) }
                self.latestRecordId = lastRecord.id
                logger.debug("가장 최근 레코드의 행동 추천 \(lastRecord.actionTexts.count)개 로드")
            }
        } catch {
            logger.error("레코드 로드 실패: \(error)")
        }
    }

    func updateActionCompletion() async {
        // capture
        guard let recordId = latestRecordId else {
            logger.error("업데이트할 레코드 ID가 없습니다.")
            return
        }
        let mentoryDB = owner!.mentoryDB
        let completionStatus = actionKeyWordItems.map { $0.1 }

        // process
        do {
            try await mentoryDB.updateActionCompletion(recordId: recordId, completionStatus: completionStatus)
            logger.debug("행동 추천 완료 상태가 업데이트되었습니다.")
        } catch {
            logger.error("행동 추천 완료 상태 업데이트 실패: \(error)")
        }
    }
}
