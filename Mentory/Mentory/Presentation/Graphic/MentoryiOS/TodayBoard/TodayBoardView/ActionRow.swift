//
//  ActionRow.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import SwiftUI


// MARK: View
struct ActionRow: View {
    @State private var isSelected: Bool = false
    let checked: Bool
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack {
                // 바깥원
                Circle()
                    .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                    .frame(width: 20, height: 20)
                // 선택시 채워지는 원
                if isSelected {
                    Circle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 12, height: 12)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
                }
            }
            .frame(width: 20, height: 20)
            
            Text(text.isEmpty ? " " : text)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.8))
            
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
            // Glass stroke (더 진하게)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 3)
        .onTapGesture {
            withAnimation {
                isSelected.toggle()
            }
        }
    }
}



// MARK: Preview
#Preview(traits: .sizeThatFitsLayout) {
    ActionRow(checked: true, text: "안녕하세요")
    
    ActionRow(checked: false, text: "체크되지 않은 ActionRow입니다.")
}


