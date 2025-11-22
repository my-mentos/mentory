//
//  MentoryRecord.swift
//  Mentory
//
//  Created by 구현모 on 11/19/25.
//

import SwiftData
import Foundation


// MARK: Model
@Model
final class MentoryRecord {
    // MARK: 기본 정보
    var id: UUID
    var recordDate: Date

    // MARK: AI 분석 결과
    var analyzedContent: String?
    var emotionType: String?

    // MARK: 메타 데이터
    var completionTimeInSeconds: TimeInterval?


    // MARK: Initializer
    init(
        id: UUID = UUID(),
        recordDate: Date = Date(),
        analyzedContent: String? = nil,
        emotionType: String? = nil,
        completionTimeInSeconds: TimeInterval? = nil
    ) {
        self.id = id
        self.recordDate = recordDate
        self.analyzedContent = analyzedContent
        self.emotionType = emotionType
        self.completionTimeInSeconds = completionTimeInSeconds
    }
}
