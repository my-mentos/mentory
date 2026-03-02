//
//  BadgeView.swift
//  Mentory
//
//  Created by 구현모 on 12/8/25.
//
import SwiftUI
import Values


// MARK: View
struct BadgeGridView: View {
    let earnedBadges: [BadgeType]
    let completedCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("완료된 제안: \(completedCount)개")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(BadgeType.allCases, id: \.self) { badgeType in
                    BadgeItemView(
                        badgeType: badgeType,
                        isEarned: earnedBadges.contains(badgeType)
                    )
                }
            }
        }
    }
}


// MARK: Component
fileprivate struct BadgeItemView: View {
    let badgeType: BadgeType
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isEarned ? [
                                Color.mentoryAccentPrimary,
                                Color.mentoryAccentPrimary.opacity(0.7)
                            ] : [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: badgeType.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isEarned ? .white : .gray.opacity(0.5))
            }

            Text(badgeType.rawValue)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isEarned ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .opacity(isEarned ? 1.0 : 0.5)
    }
}


// MARK: Preview
#Preview {
    VStack {
        LiquidGlassCard {
            BadgeGridView(
                earnedBadges: [.first, .five, .ten],
                completedCount: 12
            )
        }
        .padding()
    }
    .background(Color.mentoryBackground)
}
