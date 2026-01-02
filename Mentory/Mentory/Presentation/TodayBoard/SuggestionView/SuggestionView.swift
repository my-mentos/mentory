//
//  SuggestionView.swift
//  Mentory
//
//  Created by 김민우 on 12/4/25.
//
import Foundation
import SwiftUI



// MARK: View
struct SuggestionView: View {
    
    // MARK: model
    @ObservedObject var suggestion: Suggestion
    // MARK: body
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack {
                // 바깥 원
                Circle()
                    .stroke(Color.mentoryBorder, lineWidth: 2)
                    .frame(width: 20, height: 20)
                
                // 완료 상태 표시 원
                if suggestion.isDone {
                    Circle()
                        .fill(Color.mentoryAccentPrimary)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(
                            .spring(response: 0.25, dampingFraction: 0.7),
                            value: suggestion.isDone
                        )
                }
                
            }
            .frame(width: 20, height: 20)
            
            Text(suggestion.content.isEmpty ? " " : suggestion.content)
                .font(.system(size: 16))
                .foregroundColor(suggestion.isDone ? .secondary : .primary)
                .strikethrough(suggestion.isDone, color: .secondary)
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.20),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 3)
        .onTapGesture {
            withAnimation {
                suggestion.isDone = true
                print("TapTapTap")
            }
            Task {
                await suggestion.markDone()
            }
        }
    }
}


// MARK: Preview
fileprivate struct SuggestionPreview: View {
    var body: some View {
        Text("SuggestionPreview 프리뷰")
    }
}

#Preview {
    SuggestionPreview()
}


