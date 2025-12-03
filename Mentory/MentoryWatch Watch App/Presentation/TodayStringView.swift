//
//  TodayStringView.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/19/25.
//

import SwiftUI

struct TodayStringView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 멘토 캐릭터 아이콘
                Image(systemName: getMentorIcon())
                    .font(.system(size: 40))
                    .foregroundColor(getMentorColor())

                // 멘토 타이틀
                Text(getMentorTitle())
                    .font(.headline)

                // 멘토 메시지
                Text(connectivityManager.mentorMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .task {
            connectivityManager.loadInitialData()
        }
    }

    private func getMentorIcon() -> String {
        switch connectivityManager.mentorCharacter {
        case "cool":
            return "brain.head.profile"
        case "warm":
            return "cloud.fill"
        default:
            return "quote.bubble.fill"
        }
    }

    private func getMentorColor() -> Color {
        switch connectivityManager.mentorCharacter {
        case "cool":
            return .cyan
        case "warm":
            return .pink
        default:
            return .blue
        }
    }

    private func getMentorTitle() -> String {
        switch connectivityManager.mentorCharacter {
        case "cool":
            return "냉철이의 현실 조언"
        case "warm":
            return "구름이의 따뜻한 한마디"
        default:
            return "멘토 메시지"
        }
    }
}

#Preview {
    TodayStringView()
}
