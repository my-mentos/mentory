//
//  ActionButtonLabel.swift
//  Mentory
//
//  Created by JAY,김민우 on 11/20/25.
//
import Foundation
import SwiftUI


// MARK: Component
struct ActionButtonLabel: View {
    // MARK: variable
    let text: String
    let usage: Usage
    
    
    // MARK: body
    var body: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: usage.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(usage.strokeOpacity), lineWidth: 1)
            )
            .shadow(
                color: usage.shadowColor,
                radius: 8,
                x: 0,
                y: 4
            )
            .animation(.easeInOut(duration: 0.2), value: usage)
    }
    
    
    // MARK: value
    struct Usage: Equatable {
        // MARK: core
        let gradientColors: [Color]
        let strokeOpacity: Double
        let shadowColor: Color
        
        private init(gradientColors: [Color], strokeOpacity: Double, shadowColoe: Color) {
            self.gradientColors = gradientColors
            self.strokeOpacity = strokeOpacity
            self.shadowColor = shadowColoe
        }
        
        static let cancel: Self = Usage(
            gradientColors: [Color.red, Color.red.opacity(0.8)],
            strokeOpacity: 0.5,
            shadowColoe: Color.red.opacity(0.3)
        )
        
        static let submitEnabled: Self = Usage(
            gradientColors: [Color.blue, Color.blue.opacity(0.8)],
            strokeOpacity: 0.5,
            shadowColoe: Color.blue.opacity(0.3)
        )
        
        static let submitDisabled: Self = Usage(
            gradientColors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
            strokeOpacity: 0.2,
            shadowColoe: .clear
        )
    }

}



// MARK: Preview
#Preview {
    ActionButtonLabel(text: "완료", usage: .submitDisabled)
}

