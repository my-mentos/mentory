//
//  ActionButtonLabel.swift
//  Mentory
//
//  Created by JAY on 11/20/25.
//

import Foundation
import SwiftUI

enum ActionButtonType {
    //취소버튼
    case cancel
    //완료버튼
    case submit(enabled: Bool)
}

struct ActionButtonLabel: View {
    let text: String
    let type: ActionButtonType
    
    var body: some View {
        // 색상 정의
            let gradientColors: [Color]
            let strokeOpacity: Double
            let shadowColor: Color
            
            switch type {
            case .cancel:
                gradientColors = [Color.red, Color.red.opacity(0.8)]
                strokeOpacity = 0.5
                shadowColor = Color.red.opacity(0.3)

            case .submit(let enabled):
                gradientColors = enabled
                    ? [Color.blue, Color.blue.opacity(0.8)]
                    : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                strokeOpacity = enabled ? 0.5 : 0.2
                shadowColor = enabled ? Color.blue.opacity(0.3) : .clear
            }
            
            return Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
                )
                .shadow(
                    color: shadowColor,
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .animation(.easeInOut(duration: 0.2), value: {
                    if case .submit(let enabled) = type { return enabled }
                    return true
                }())
    }
}
