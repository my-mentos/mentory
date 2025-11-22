//
//  DailyRecordAdapter.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//
import Foundation


// MARK: Adapter
nonisolated struct DailyRecordAdapter: DailyRecordInterface {
    @concurrent
    func delete() async throws {
        fatalError()
    }
}
