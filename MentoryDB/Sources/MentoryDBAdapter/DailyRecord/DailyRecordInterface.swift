//
//  DailyRecordInterface.swift
//  MentoryDB
//
//  Created by 김민우 on 11/22/25.
//
import Values
import Foundation


// MARK: Interface
protocol DailyRecordInterface: Sendable {
    func getSuggestions() async throws -> [SuggestionData]
}
