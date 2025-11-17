//
//  AlanLLM.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import OSLog


// MARK: Flow
protocol AlanLLMFlow: Sendable {
    func question(token: AlanLLM.AuthToken, question: AlanLLM.Question) async -> AlanLLM.Answer
    func resetState(token: AlanLLM.AuthToken) async
}


// MARK: Domain
nonisolated
struct AlanLLM: AlanLLMFlow {
    // MARK: core
    nonisolated let id: UUID
    nonisolated let logger = Logger(subsystem: "AlanLLM.AlanLLMFlow", category: "Domain")
    init(_ id: UUID) {
        self.id = id
    }
    
    
    // MARK: flow
    @concurrent
    func question(token: AuthToken, question: Question) async -> Answer {
        fatalError()
    }
    
    @concurrent
    func resetState(token: AuthToken) async {
        fatalError()
    }
    

    
    // MARK: value
    nonisolated
    enum Error: Swift.Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case networkError(Swift.Error)
        case decodingError(Swift.Error)
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
    
    nonisolated
    struct Question: Sendable, Hashable, Identifiable {
        // MARK: codr
        let id: ID = ID()
        let content: String
        
        init(_ content: String) {
            self.content = content
        }
        
        
        // MARK: value
        struct ID: Sendable, Hashable {
            let rawValue = UUID()
        }
    }
    
    nonisolated
    struct Answer: Sendable, Codable {
        // MARK: core
        let action: Action
        let content: String
        
        nonisolated
        struct Action: Sendable, Codable {
            let name: String
            let speak: String
        }
    }
    
    nonisolated
    struct AuthToken {
        // MARK: core
        let value: String
        init(_ value: String) {
            self.value = value
        }
        
        static let current: AuthToken = .init(
            {
                guard let token = Bundle.main.object(forInfoDictionaryKey: "ALAN_API_TOKEN") as? String,
                      !token.isEmpty else {
                    fatalError("ALAN_API_TOKEN이 Info.plist에 설정되지 않았습니다. Secrets.xcconfig의 TOKEN 값을 Info.plist에 추가해주세요.")
                }
                return token
            }()
        )
    }
    
    nonisolated
    struct ID: Sendable, Hashable {
        // MARK: core
        let value: URL
        init(_ value: URL) {
            self.value = value
        }
    }
}
