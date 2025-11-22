//
//  VoiceRecordView.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/19/25.
//

import SwiftUI

struct VoiceRecordView: View {
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 20) {
            // 녹음 아이콘
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.system(size: 40))
                    .foregroundColor(isRecording ? .red : .gray)
            }

            // 녹음 버튼
            Button(action: {
                isRecording.toggle()
            }) {
                Text(isRecording ? "녹음 중지" : "녹음 시작")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(isRecording ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)

            if isRecording {
                Text("녹음 중...")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    VoiceRecordView()
}
