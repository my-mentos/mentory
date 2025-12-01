//
//  OnboardingDetailView.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import SwiftUI


// MARK: Component
struct OnboardingDetailView: View {
    let title: String
    let subtitle: String
    let image: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 클립보드 아이콘
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.mentoryAccentPrimary)


            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.bottom, 10)
    }
}
