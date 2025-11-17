//
//  MindAnalyzer.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//

import Foundation
import Combine

// MARK: Object
@MainActor
final class MindAnalyzer: Sendable, ObservableObject {
    // MARK: core
    init(owner: RecordForm) { self.owner = owner }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: RecordForm?
    @Published var isAnalyzing: Bool = true
    @Published var selectedCharacter: CharacterType? = nil
    @Published var mindType: MindType? = nil
    @Published var analyzedResult: String? = nil
    
    
    // MARK: action
    // 분석(LLM에게 보내서) >> 결과 기다려서 반환해야 하는지?(이파일에서 가지고 있어야하는지)
    // RecordForm에서 갖고있는 사용자가 입력한 여러 상태들을
    func startAnalyzing() {
        // capture
        let textInput = owner?.textInput ?? ""
        guard textInput.isEmpty == false else {
            return
        }
        //guard let imageInput = owner?.imageInput else { return }
        //guard let voiceInput = owner?.voiceInput else { return }
        
        // process
        isAnalyzing = true
        analyzedResult = nil
        selectedCharacter = CharacterType.A
        Task {
            await self.callAPI(prompt: textInput, character: .A)
            self.isAnalyzing = false
        }
        
        // mutate
        
        
    }
    
    // 결과 오는지만 확인용
    func callAPI(prompt: String, character: CharacterType) async {
        // capture
        let alanClientKey = Bundle.main.object(forInfoDictionaryKey: "ALAN_CLIENT_KEY") as Any
            print("🔑 ALAN_CLIENT_KEY raw:", alanClientKey)
        
        print("ALAN_CLIENT_KEY =", alanClientKey)
        
        guard let clientKey = Bundle.main.object(forInfoDictionaryKey: "ALAN_CLIENT_KEY") as? String,
              clientKey.isEmpty == false else {
            print("ALAN_CLIENT_KEY 없음")
            return
        }
        var urlBuilder = URLComponents(string: "https://kdt-api-function.azurewebsites.net/api/v1/question")!
        urlBuilder.queryItems = [
            URLQueryItem(name: "client_key", value: clientKey),
            URLQueryItem(name: "content", value: prompt)
        ]
        
        guard let requestURL = urlBuilder.url else {
            print("URL 생성 실패")
            return
        }
        
        // process
        do {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            let text = String(data: data, encoding: .utf8) ?? ""
            print("요청 결과:", text)
            
            mindType = MindType.slightlyUnpleasant
            self.analyzedResult = text
            
        } catch {
            print("요청 실패:", error)
        }
        
        // mutate
    }
    
    
    // MARK: value
    
    enum CharacterType: Sendable {
        case A
        case B
    }
    
    enum MindType: Sendable {
        case veryUnpleasant
        case unPleasant
        case slightlyUnpleasant
        case neutral
        case slightlyPleasant
        case pleasant
        case veryPleasant
    }
}
