//
//  AlanAPIService.swift
//  Mentory
//
//  Created by 구현모 on 11/17/25.
//

import Foundation
import OSLog

final class AlanAPIService {
    // MARK: - Singleton
    static let shared = AlanAPIService()

    // MARK: - Properties
    private let baseURL = "https://kdt-api-function.azurewebsites.net/api/v1"
    private let logger = Logger(subsystem: "MentoryLLM.AlanAPI", category: "Service")

    // MARK: - Init
    private init() {}

    // MARK: - API Methods

    /// 질문하기 API - 일반 응답
    /// - Parameter content: 질문 내용
    /// - Returns: Alan API 응답
    func question(content: String) async throws -> AlanAPIResponse {
        guard var urlComponents = URLComponents(string: "\(baseURL)/question") else {
            logger.error("URL 생성 실패")
            throw AlanAPIError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "content", value: content),
            URLQueryItem(name: "client_id", value: Config.alanAPIClientID)
        ]

        guard let url = urlComponents.url else {
            logger.error("URL Components로부터 URL 생성 실패")
            throw AlanAPIError.invalidURL
        }

        logger.info("API 요청: \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("HTTP 응답 변환 실패")
                throw AlanAPIError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                logger.error("HTTP 오류: 상태 코드 \(httpResponse.statusCode)")
                throw AlanAPIError.httpError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(AlanAPIResponse.self, from: data)

            logger.info("API 응답 성공: \(apiResponse.content)")
            return apiResponse

        } catch let error as DecodingError {
            logger.error("디코딩 오류: \(error.localizedDescription)")
            throw AlanAPIError.decodingError(error)
        } catch let error as AlanAPIError {
            throw error
        } catch {
            logger.error("네트워크 오류: \(error.localizedDescription)")
            throw AlanAPIError.networkError(error)
        }
    }

    /// 에이전트 상태 초기화
    func resetState() async throws {
        guard let url = URL(string: "\(baseURL)/reset-state") else {
            logger.error("URL 생성 실패")
            throw AlanAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["client_id": Config.alanAPIClientID]
        request.httpBody = try JSONEncoder().encode(requestBody)

        logger.info("상태 초기화 요청")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("HTTP 응답 변환 실패")
                throw AlanAPIError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                logger.error("HTTP 오류: 상태 코드 \(httpResponse.statusCode)")
                throw AlanAPIError.httpError(statusCode: httpResponse.statusCode)
            }

            logger.info("상태 초기화 성공")

        } catch let error as AlanAPIError {
            throw error
        } catch {
            logger.error("네트워크 오류: \(error.localizedDescription)")
            throw AlanAPIError.networkError(error)
        }
    }
}
