//
//  ActionTodoView.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/19/25.
//

import SwiftUI

struct ActionTodoView: View {
    @State private var todoItems = [
        TodoItem(text: "산책하기", isCompleted: false),
        TodoItem(text: "물 마시기", isCompleted: true),
        TodoItem(text: "스트레칭", isCompleted: false)
    ]

    var body: some View {
        List {
            Section {
                ForEach($todoItems) { $item in
                    HStack {
                        Button(action: {
                            item.isCompleted.toggle()
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .gray)
                        }
                        .buttonStyle(.plain)

                        Text(item.text)
                            .strikethrough(item.isCompleted)
                            .foregroundColor(item.isCompleted ? .gray : .primary)
                    }
                }
            } header: {
                Text("오늘의 행동 추천")
            }
        }
    }
}

struct TodoItem: Identifiable {
    let id = UUID()
    var text: String
    var isCompleted: Bool
}

#Preview {
    ActionTodoView()
}
