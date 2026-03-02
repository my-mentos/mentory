//
//  MentoryWidgetControl.swift
//  MentoryWidget
//
//  Created by SJS on 11/19/25.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - 앱과 위젯의 공용 저장소

struct ActionWidgetStorage {
    // appGroupID에 맞게 수정 필요
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
        return value == 0 ? (7.0 / 9.0) : value
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

// MARK: - Timeline Entry (위젯을 그릴 때 필요한 데이터 세트)

struct ActionEntry: TimelineEntry {
    let date: Date
    let isCompleted: Bool
    let progress: Double
}

// MARK: - Provider
// 시스템 → Provider.timeline 호출 → loadEntry() → ActionEntry → View에게 전달

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
        // 이 위젯은 내부에서만 상태를 바꾸므로 .never 사용 (자동 갱신x)
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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("오늘은 이런 행동 어떨까요?")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("7/9")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.secondary.opacity(0.15))
                        .frame(height: 6)

                    GeometryReader { geo in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .purple,
                                        .purple.opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * entry.progress, height: 6)
                    }
                }
                .frame(height: 6)

                Button {
                } label: {
                    ZStack {
                        Circle()
                            .fill(.secondary.opacity(0.12))

                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 24, height: 24)
            }

            // 체크 영역 전체가 버튼
            Button(intent: ToggleRecommendedActionIntent()) {
                HStack(spacing: 8) {
                    Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(entry.isCompleted ? Color.accentColor : Color.secondary)

                    Text(entry.isCompleted
                         ? "오늘의 추천행동을 완료했어요!"
                         : "기록을 남기고 추천행동을 완료해보세요!")
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.systemBackground).opacity(0.8))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "mentory://record"))
    }
}

// MARK: - 위에 있는 View를 진짜 Widget으로 정의

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
        .supportedFamilies([.systemMedium])   // 위젯 크기 (스몰, 미디움, 라지)
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    MentoryActionWidget()
} timeline: {
    ActionEntry(date: .now, isCompleted: false, progress: 7.0 / 9.0)
}
