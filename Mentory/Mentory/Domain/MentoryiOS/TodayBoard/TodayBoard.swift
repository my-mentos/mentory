//
//  TodayBoard.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
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
    nonisolated let owner: MentoryiOS
    nonisolated let id = UUID()
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")

    var recordForm: RecordForm? = nil
    @Published var records: [Record] = []

    
    @Published var todayString: String? = nil

    // MARK: action
    func fetchTodayString() async {
        let candidates: [String] = [
            "먼저핀꽃은 먼저진다 남보다 먼저 공을 세우려고 조급히 서둘것이 아니다",
            "삶이 있는 한 희망은 있다",
            "피할수 없으면 즐겨라",
            "우리를 향해 열린 문을 보지 못하게 된다",
            "피할수 없으면 즐겨라"
        ]
        
        guard let randomQuote = candidates.randomElement() else {
            logger.error("현재 명언이 존재하지 않습니다.")
            return
        }
        
        self.todayString = randomQuote
    }
    
    func addRecord(_ record: Record) {
        records.append(record)
        logger.info("새로운 기록이 추가되었습니다. ID: \(record.id)")
    }


    // MARK: value
    struct Record: Identifiable, Sendable, Hashable {
        let id: UUID
        let title: String
        let date: Date
        let text: String?
        let image: Data?
        let voice: URL?

        init(id: UUID = UUID(), title: String, date: Date, text: String? = nil, image: Data? = nil, voice: URL? = nil) {
            self.id = id
            self.title = title
            self.date = date
            self.text = text
            self.image = image
            self.voice = voice
        }
    }
}
