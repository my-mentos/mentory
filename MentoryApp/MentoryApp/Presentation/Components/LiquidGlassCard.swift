//
//  LiquidGlassCard.swift
//  Mentory
//
//  Created by JAY on 11/20/25.
//
import Foundation
import SwiftUI


// MARK: Component
struct LiquidGlassCard<Content: View>: View {
    // MARK: variable
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let content: Content
    
    init(cornerRadius: CGFloat = 28,
         shadowRadius: CGFloat = 18,
         @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.content = content()
    }

    
    // MARK: body
    var body: some View {
        content
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.4))
            )
            .shadow(color: Color.black.opacity(0.08),
                    radius: shadowRadius, x: 0, y: 10)
    }
}



// MARK: Preview
#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()
        
        LiquidGlassCard {
            VStack(spacing: 12) {
                Text("Liquid Glass Card")
                    .font(.title3.bold())
                Text("샘플 프리뷰입니다.")
            }
            .padding()
        }
    }
}
