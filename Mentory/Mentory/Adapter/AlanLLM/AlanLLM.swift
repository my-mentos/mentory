//
//  AlanLLM.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import OSLog
import Values


// MARK: Interface
protocol AlanLLMInterface: Sendable {
    func question(_ question: AlanQuestion) async throws -> AlanLLM.Answer
}


// MARK: Domain
nonisolated
struct AlanLLM: AlanLLMInterface {
    // MARK: core
    nonisolated let id = ID(URL(string: "https://kdt-api-function.azurewebsites.net/api/v1")!)
    nonisolated let logger = Logger(subsystem: "AlanLLM.AlanLLMFlow", category: "Domain")
    
    
    // MARK: flows
    @concurrent
    func question(_ question: AlanQuestion) async throws -> Answer {
        logger.debug("question() 시작 - 질문 전송 준비")
        
        let token = AuthToken.current
        logger.debug("question() - 토큰 로드 완료 (길이: \(token.value.count))")
        
        guard var urlComponents = URLComponents(string: "\(id.value.absoluteString)/question") else {
            logger.error("question() - URLComponents 생성 실패: baseURL=\(id.value.absoluteString, privacy: .public)")
            throw AlanLLM.Error.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "content", value: question.content),
            URLQueryItem(name: "client_id", value: token.value)
        ]
        logger.debug("question() - URLComponents 구성 완료: \(urlComponents.debugDescription, privacy: .public)")
        
        guard let url = urlComponents.url else {
            logger.error("question() - URL Components로부터 URL 생성 실패")
            throw AlanLLM.Error.invalidURL
        }
        
        logger.debug("question() - 최종 URL 생성: \(url.absoluteString, privacy: .public)")
        
        do {
            logger.debug("question() - 네트워크 요청 시작")
            let (data, response) = try await URLSession.shared.data(from: url)
            logger.debug("question() - 네트워크 응답 수신 (bytes: \(data.count))")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("question() - HTTPURLResponse 캐스팅 실패")
                throw AlanLLM.Error.invalidResponse
            }
            
            logger.debug("question() - 상태 코드: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                logger.error("question() - HTTP 오류: 상태 코드 \(httpResponse.statusCode)")
                if let bodyString = String(data: data, encoding: .utf8) {
                    logger.error("question() - 오류 응답 바디: \(bodyString, privacy: .public)")
                } else {
                    logger.error("question() - 오류 응답 바디 디코딩 실패")
                }
                throw AlanLLM.Error.httpError(statusCode: httpResponse.statusCode)
            }
            
            logger.debug("question() - 응답 디코딩 시작")
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(AlanLLM.Answer.self, from: data)
            
            logger.debug("question() - 디코딩 완료: action=\(apiResponse.action.name, privacy: .public)")
            return apiResponse
            
        } catch let decodingError as DecodingError {
            logger.error("question() - 디코딩 오류 발생: \(String(describing: decodingError), privacy: .public)")
            throw AlanLLM.Error.decodingError(decodingError)
        } catch let alanError as AlanLLM.Error {
            logger.error("question() - AlanLLM.Error 발생: \(String(describing: alanError), privacy: .public)")
            throw alanError
        } catch {
            logger.error("question() - 네트워크 오류 발생: \(error.localizedDescription, privacy: .public)")
            throw AlanLLM.Error.networkError(error)
        }
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
    struct Answer: Sendable, Codable {
        // MARK: core
        let action: Action
        let content: String
        
        nonisolated
        struct Action: Sendable, Codable {
            let name: String
            let speak: String
        }
        
        // MARK: operator
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
        fileprivate init(_ value: URL) {
            self.value = value
        }
    }
}
