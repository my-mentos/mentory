//
//  Config.swift
//  Mentory
//
//  Created by 구현모 on 11/17/25.
//

import Foundation

enum Config {
    // MARK: - Alan API Configuration

    /// Alan API Client ID (Secrets.xcconfig의 TOKEN 값)
    /// Info.plist에 ALAN_API_TOKEN = $(TOKEN) 형태로 등록되어야 합니다.
    static var alanAPIClientID: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "ALAN_API_TOKEN") as? String,
              !token.isEmpty else {
            fatalError("ALAN_API_TOKEN이 Info.plist에 설정되지 않았습니다. Secrets.xcconfig의 TOKEN 값을 Info.plist에 추가해주세요.")
        }
        return token
    }
}
