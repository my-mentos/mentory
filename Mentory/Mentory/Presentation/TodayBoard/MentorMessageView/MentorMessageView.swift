//
//  MentorMessageView.swift
//  Mentory
//
//  Created by 김민우 on 12/4/25.
//
import Foundation
import SwiftUI
import Values



// MARK: View
struct MentorMessageView: View {
    // MARK: model
    @ObservedObject var mentorMessage: MentorMessage
    
    
    // MARK: body
    var body: some View {
        PopupCard(
            image: mentorMessage.character?.imageName,
            defaultImage: "greeting",
            title: mentorMessage.character?.title,
            defaultTitle: "오늘의 멘토리 조언을 준비하고 있어요",
            content: mentorMessage.content,
            defaultContent: "잠시 후 당신을 위한 멘토리 메시지가 도착해요\n오늘은 냉철이일까요, 구름이일까요?\n조금만 기다려 주세요"
        )
        .task {
            await mentorMessage.updateContent()
        }
    }
}

struct PopupCard: View {
    let image: String?
    let defaultImage: String
    let title: String?
    let defaultTitle: String
    let content: String?
    let defaultContent: String
    
    private func forMarkdown(_ string: String) -> LocalizedStringKey {
        .init(string)
    }
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(image ?? defaultImage)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(1.8, anchor: .top)
                        .offset(y: 2)
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.25), lineWidth: 0.5)
                        )
                    Text(title ?? defaultTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                
                
                Text(forMarkdown(content ?? defaultContent))
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .transition(.scale(scale: 0.95).combined(with: .opacity))
    }
}


// MARK: Preview
fileprivate struct MentorMessagePreview: View {
    var body: some View {
        Text("프리뷰")
    }
}

#Preview {
    MentorMessagePreview()
}

