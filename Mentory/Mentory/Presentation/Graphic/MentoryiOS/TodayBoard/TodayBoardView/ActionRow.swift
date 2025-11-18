//
//  ActionRow.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import SwiftUI


// MARK: View
struct ActionRow: View {
    let checked: Bool
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
            } else {
                // 체크 없을 때 간격 맞추기용
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 18, height: 18)
            }
            
            Text(text.isEmpty ? " " : text)
                .font(.system(size: 16))
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
        )
    }
}


// MARK: Preview
#Preview(traits: .sizeThatFitsLayout) {
    ActionRow(checked: true, text: "안녕하세요")
    
    ActionRow(checked: false, text: "체크되지 않은 ActionRow입니다.")
}


