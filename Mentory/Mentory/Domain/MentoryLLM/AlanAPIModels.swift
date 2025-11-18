//
//  AlanAPIModels.swift
//  Mentory
//
//  Created by 구현모 on 11/17/25.
//

import Foundation

// MARK: - Alan API Response Models
struct AlanAPIResponse: Codable {
    let action: AlanAction
    let content: String
}

struct AlanAction: Codable {
    let name: String
    let speak: String
}

// MARK: - Alan API Error
enum AlanAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "서버 응답이 유효하지 않습니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "데이터 파싱 오류: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP 오류 (상태 코드: \(statusCode))"
        }
    }
}
