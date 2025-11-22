//
//  MentoryRecordRepository.swift
//  Mentory
//
//  Created by 구현모 on 11/19/25.
//

import SwiftData
import Foundation


// MARK: Domain Interface
protocol MentoryRecordRepositoryInterface: Sendable {
    // Record를 저장
    func save(_ record: MentoryRecord) async throws
    
    // 저장된 Record를 불러옴
    func fetchAll() async throws -> [MentoryRecord]
    func fetchToday() async throws -> [MentoryRecord]
    func fetchByDateRange(from: Date, to: Date) async throws -> [MentoryRecord]
    func delete(_ record: MentoryRecord) async throws
}


// MARK: Domain
@MainActor
final class MentoryRecordRepository: MentoryRecordRepositoryInterface {
    // MARK: core
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }


    // MARK: flow
    func save(_ record: MentoryRecord) async throws {
        modelContext.insert(record)
        try modelContext.save()
    }

    func fetchAll() async throws -> [MentoryRecord] {
        let descriptor = FetchDescriptor<MentoryRecord>(
            sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchToday() async throws -> [MentoryRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<MentoryRecord> { record in
            record.recordDate >= today && record.recordDate < tomorrow
        }

        let descriptor = FetchDescriptor<MentoryRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchByDateRange(from: Date, to: Date) async throws -> [MentoryRecord] {
        let predicate = #Predicate<MentoryRecord> { record in
            record.recordDate >= from && record.recordDate <= to
        }

        let descriptor = FetchDescriptor<MentoryRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func delete(_ record: MentoryRecord) async throws {
        modelContext.delete(record)
        try modelContext.save()
    }
}
