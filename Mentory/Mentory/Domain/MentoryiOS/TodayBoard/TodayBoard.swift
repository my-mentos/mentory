//
//  TodayBoard.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
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
    
    // MARK: value
}
