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
    init(owner: MentoryiOS, recordRepository: MentoryRecordRepositoryInterface? = nil) {
        self.owner = owner
        self.recordRepository = recordRepository
    }


    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryiOS?
    var recordRepository: MentoryRecordRepositoryInterface?
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")

    @Published var recordForm: RecordForm? = nil
    @Published var records: [MentoryRecord] = []

    @Published var todayString: String? = nil
    @Published var isFetchedTodayString: Bool = false

    
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

    func saveRecord(_ record: MentoryRecord) async {
        // capture
        guard let repository = recordRepository else {
            logger.error("RecordRepository가 설정되지 않았습니다.")
            return
        }

        // process
        do {
            try await repository.save(record)
            logger.info("레코드 저장 성공: \(record.id)")

            // 저장 후 오늘의 레코드 다시 로드
            await loadTodayRecords()
        } catch {
            logger.error("레코드 저장 실패: \(error)")
        }
    }

    func loadTodayRecords() async {
        // capture
        guard let repository = recordRepository else {
            logger.error("RecordRepository가 설정되지 않았습니다.")
            return
        }

        // process
        do {
            let todayRecords = try await repository.fetchToday()
            logger.info("오늘의 레코드 \(todayRecords.count)개 로드 성공")

            // mutate
            self.records = todayRecords
        } catch {
            logger.error("레코드 로드 실패: \(error)")
        }
    }


    // MARK: value
}
