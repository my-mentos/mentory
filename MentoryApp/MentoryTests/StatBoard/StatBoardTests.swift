//
//  StatBoardTests.swift
//  Mentory
//
//  Created by 김민우 on 2/25/26.
//
import Foundation
import Testing
import Values
import MentoryDBAdapter
@testable import MentoryCore


// MARK: Tests
@Suite("StatBoard")
struct StatBoardTests {
    struct Init {
        let mentoryiOS: Mentory
        let statBoard: StatBoard
        init() async throws {
            self.mentoryiOS = await Mentory()
            self.statBoard = try await getStatBoardForTest(mentoryiOS)
        }
        
        @Test func isAllRecordsEmpty() async {
            await #expect(statBoard.allRecords.isEmpty)
        }
    }
    
    struct LoadRecords {
        let mentoryiOS: Mentory
        let statBoard: StatBoard
        let mentoryDB: any MentoryDBInterface
        init() async throws {
            self.mentoryiOS = await Mentory()
            self.statBoard = try await getStatBoardForTest(mentoryiOS)
            self.mentoryDB = mentoryiOS.mentoryDB
        }
        
        @Test func updateAllRecords() async throws {
            // given
            try await #require(statBoard.allRecords.isEmpty == true)
            
            // 새로운 Record의 생성
            let sampleRecordData = RecordData(
                recordDate: .now,
                analyzedResult: "SAMPLE_ANALYSIS",
                emotion: .neutral)
            
            try await mentoryDB.submitAnalysis(
                recordData: sampleRecordData,
                suggestionData: []
            )
            
            // when
            await statBoard.loadRecords()
            
            // then
            await #expect(statBoard.allRecords.isEmpty == false)
        }
    }
}


// MARK: Helpher
private func getStatBoardForTest(_ mentoryiOS: Mentory) async throws -> StatBoard {
    // create Onboarding
    await mentoryiOS.setUp()
    
    let onboarding = try #require(await mentoryiOS.onboarding)
    
    // create StatBoard
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    await onboarding.next()
    
    // return StatBoard
    let statBoard = try #require(await mentoryiOS.statBoard)
    
    return statBoard
}
