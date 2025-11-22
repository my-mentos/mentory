//
//  DailyRecordInterface.swift
//  Mentory
//
//  Created by 김민우 on 11/22/25.
//


// MARK: Interface
protocol DailyRecordInterface: Sendable {
    func delete() async throws
}
