//
//  TodayStringView.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/19/25.
//

import SwiftUI

struct TodayStringView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 아이콘
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)

                // 제목
                Text("오늘의 명언")
                    .font(.headline)

                // 명언 내용 (임시)
                Text("노력은 배신하지 않는다")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

#Preview {
    TodayStringView()
}
