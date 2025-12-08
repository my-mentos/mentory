//
//  ActionTodoView.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/19/25.
//

import SwiftUI

struct ActionTodoView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared

    var body: some View {
        List {
            Section {
                if connectivityManager.actionTodos.isEmpty {
                    Text("투두가 없습니다")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(connectivityManager.actionTodos.enumerated()), id: \.offset) { index, todoText in
                        let isCompleted = index < connectivityManager.todoCompletionStatus.count
                            ? connectivityManager.todoCompletionStatus[index]
                            : false

                        HStack {
                            Button(action: {
                                Task {
                                    await handleTodoToggle(todoText: todoText, currentStatus: isCompleted)
                                }
                            }) {
                                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isCompleted ? .green : .gray)
                            }
                            .buttonStyle(.plain)

                            Text(todoText)
                                .strikethrough(isCompleted)
                                .foregroundColor(isCompleted ? .gray : .primary)
                        }
                    }
                }
            } header: {
                Text("오늘의 행동 추천")
            }
        }
        .task {
            // View가 나타날 때 데이터 로드
            await connectivityManager.loadInitialData()
        }
    }

    private func handleTodoToggle(todoText: String, currentStatus: Bool) async {
        // 이미 완료된 항목은 다시 해제할 수 없음
        guard !currentStatus else { return }

        let newStatus = true

        // 1. 먼저 로컬 상태 즉시 업데이트 (UI 즉시 반영)
        if let index = connectivityManager.actionTodos.firstIndex(of: todoText),
           index < connectivityManager.todoCompletionStatus.count {
            connectivityManager.todoCompletionStatus[index] = newStatus
        }

        // 2. iPhone으로 완료 상태 전송
        await connectivityManager.sendTodoCompletion(todoText: todoText, isCompleted: newStatus)
    }
}

#Preview {
    ActionTodoView()
}
