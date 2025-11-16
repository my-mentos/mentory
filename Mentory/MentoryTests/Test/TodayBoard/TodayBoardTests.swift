//
//  TodayBoardTests.swift
//  Mentory
//
//  Created by SJS on 11/14/25.
//

import Testing
import Foundation
@testable import Mentory


// MARK: Tests
@Suite("TodayBoard")
struct TodayBoardTests {
    struct FetchTodayString {
        let mentory: MentoryiOS
        let todayBoard: TodayBoard
        init() async throws {
            self.mentory = await MentoryiOS()
            self.todayBoard = try await getTodayBoardForTest(mentory)
        }
        
        @Test func setTodayString() async throws {
            // given
            try await #require(todayBoard.todayString == nil)
            
            // when
            await todayBoard.fetchTodayString()
            
            // then
            await #expect(todayBoard.todayString != nil)
        }
    }
}


// MARK: Helphers
private func getTodayBoardForTest(_ mentoryiOS: MentoryiOS) async throws -> TodayBoard {
    
    await mentoryiOS.setUp()
    
    // 온보딩 가져오기
    guard let onboarding = await mentoryiOS.onboarding else {
        throw NSError(domain: "Onboarding not initialized", code: -1)
    }
    
    // 온보딩 값 입력 + 검증
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    // 온보딩 완료
    await onboarding.next()
    
    // TodayBoard 가져오기
    guard let todayBoard = await mentoryiOS.todayBoard else {
        throw NSError(domain: "TodayBoard not initialized", code: -1)
    }
    
    return todayBoard
}
