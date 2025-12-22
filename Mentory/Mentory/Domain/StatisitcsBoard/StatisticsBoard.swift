//
//  StatisticsBoard.swift
//  Mentory
//
//  Created by SJS on 12/17/25.
//

import Foundation
import Observation
import Values

@Observable
final class StatisticsBoard {

    struct State: Equatable {
        var isLoading: Bool = false
        var allRecords: [RecordData] = []

        var selectedMonth: Date = Date()
        var selectedDate: Date? = nil
        var errorMessage: String? = nil
    }

    private(set) var state = State()
    private let mentoryDB: any MentoryDBInterface
    private let calendar = Calendar.current


    init(mentoryDB: any MentoryDBInterface) {
        self.mentoryDB = mentoryDB
        self.state.selectedMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
    }

    func load() {
        state.isLoading = true
        state.errorMessage = nil

        Task {
            do {
                let records = try await mentoryDB.getRecords()
                await MainActor.run {
                    self.state.allRecords = records
                    self.state.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.state.allRecords = []
                    self.state.isLoading = false
                    self.state.errorMessage = "통계 데이터를 불러오지 못했습니다."
                }
            }
        }
    }
    
    func selectDate(_ date: Date?) {
        state.selectedDate = date
    }
    
    func moveMonth(_ delta: Int) {
        guard let next = calendar.date(byAdding: .month, value: delta, to: state.selectedMonth) else { return }
        state.selectedMonth = next
        state.selectedDate = nil
    }
    
    func record(for day: Date) -> RecordData? {
        state.allRecords.first { record in
            calendar.isDate(record.recordDate.rawValue, inSameDayAs: day)
        }
    }
    
    func setMonth(_ date: Date) {
        let comps = calendar.dateComponents([.year, .month], from: date)
        state.selectedMonth = calendar.date(from: comps) ?? date
        state.selectedDate = nil
    }

    func goToday() {
        setMonth(Date())
        state.selectedDate = Date()
    }
}
