//
//  ContentView.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/19/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // 탭 1: 오늘의 명언
            TodayStringView()
                .tabItem {
                    Label("명언", systemImage: "quote.bubble")
                }

            // 탭 2: 행동 추천 투두
            ActionTodoView()
                .tabItem {
                    Label("투두", systemImage: "checklist")
                }

            // 탭 3: 음성 기록
            VoiceRecordView()
                .tabItem {
                    Label("기록", systemImage: "mic")
                }
        }
    }
}

#Preview {
    ContentView()
}
