//
//  MentoryWidgetControl.swift
//  MentoryWidget
//
//  Created by SJS on 11/19/25.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - 공용 저장소 헬퍼

struct ActionWidgetStorage {
    private static let appGroupID = "group.com.sjs.mentory"
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID)!
    }

    private static let completedKey = "recommendedActionCompleted"
    private static let progressKey  = "recommendedActionProgress"

    static func isCompleted() -> Bool {
        defaults.bool(forKey: completedKey)
    }

    static func setCompleted(_ newValue: Bool) {
        defaults.set(newValue, forKey: completedKey)
    }

    static func progress() -> Double {
        let value = defaults.double(forKey: progressKey)
        return value == 0 ? (7.0 / 9.0) : value   // 기본값 7/9
    }

    static func setProgress(_ newValue: Double) {
        defaults.set(newValue, forKey: progressKey)
    }
}

// MARK: - AppIntent: 체크 토글

struct ToggleRecommendedActionIntent: AppIntent {
    static let title: LocalizedStringResource = "Toggle Recommended Action"

    func perform() async throws -> some IntentResult {
        let current = ActionWidgetStorage.isCompleted()
        ActionWidgetStorage.setCompleted(!current)

        // 위젯 새로고침
        WidgetCenter.shared.reloadTimelines(ofKind: "MentoryActionWidget")
        return .result()
    }
}

// MARK: - Timeline Entry

struct ActionEntry: TimelineEntry {
    let date: Date
    let isCompleted: Bool
    let progress: Double
}

// MARK: - Provider

struct ActionProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ActionEntry {
        ActionEntry(date: .now,
                    isCompleted: false,
                    progress: 7.0 / 9.0)
    }

    func snapshot(for configuration: ConfigurationAppIntent,
                  in context: Context) async -> ActionEntry {
        loadEntry()
    }

    func timeline(for configuration: ConfigurationAppIntent,
                  in context: Context) async -> Timeline<ActionEntry> {
        let entry = loadEntry()
        // 이 위젯은 내부에서만 상태를 바꾸므로 .never 정책 사용
        return Timeline(entries: [entry], policy: .never)
    }

    private func loadEntry() -> ActionEntry {
        ActionEntry(
            date: .now,
            isCompleted: ActionWidgetStorage.isCompleted(),
            progress: ActionWidgetStorage.progress()
        )
    }
}

// MARK: - 위젯 View

struct MentoryActionWidgetEntryView: View {
    var entry: ActionProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단 헤더 (오늘은 이런 행동 어떨까요? + 7/9)
            HStack {
                Text("오늘은 이런 행동 어떨까요?")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Text("7/9")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
            }

            // Progress Bar
            HStack(spacing: 8) {
                ZStack {
                    Capsule()
                        .fill(.gray.opacity(0.12))
                        .frame(height: 10)
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        )

                    GeometryReader { geo in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .purple,
                                        .purple.opacity(0.55)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geo.size.width * entry.progress)
                            .shadow(color: .purple.opacity(0.3),
                                    radius: 3, x: 0, y: 1)
                    }
                }
                .frame(height: 10)

                Button {
                    // TODO: 추후 추천 행동 새로고침 AppIntent 연결 가능
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(6)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(
                Color.white.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )

            // 하단 체크 + 텍스트 (오늘의 추천행동 완료 체크)
            HStack(spacing: 8) {
                Button(intent: ToggleRecommendedActionIntent()) {
                    Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18, weight: .semibold))
                }

                Text(entry.isCompleted
                     ? "오늘의 추천행동을 완료했어요!"
                     : "기록을 남기고 추천행동을 완료해보세요!")
                .font(.system(size: 13))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            // LiquidGlassCard와 비슷한 느낌의 카드 배경 (간단 버전)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.9))
                .shadow(color: Color.black.opacity(0.08),
                        radius: 10, x: 0, y: 6)
        )
        // 카드 전체를 탭하면 기록 탭으로 이동
        .widgetURL(URL(string: "mentory://record"))
    }
}

// MARK: - Widget 정의

struct MentoryActionWidget: Widget {
    let kind: String = "MentoryActionWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: ConfigurationAppIntent.self,
                               provider: ActionProvider()) { entry in
            MentoryActionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘의 추천행동")
        .description("추천행동과 진행률을 확인하고 완료 여부를 체크할 수 있어요.")
        .supportedFamilies([.systemMedium])   // 필요에 따라 small/large 추가 가능
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    MentoryActionWidget()
} timeline: {
    ActionEntry(date: .now, isCompleted: false, progress: 7.0 / 9.0)
}
