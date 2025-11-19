//
//  MentoryWidget.swift
//  MentoryWidget
//
//  Created by SJS on 11/19/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        return Timeline(entries: [entry], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct MentoryWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        HStack(spacing: 12) {

            // 캐릭터 이미지
            Image("gureum")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("아직 일기를 작성하지 않으셨군요.")
                    .font(.headline)

                Text("오늘의 감정을 간단히 기록해보세요!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "mentory://record")) // 위젯 눌렀을 때 기록탭으로 이동
    }
}

struct MentoryWidget: Widget {
    let kind: String = "MentoryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: ConfigurationAppIntent.self,
                               provider: Provider()) { entry in
            MentoryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mentory 일기 위젯")
        .description("일기를 빠르게 작성할 수 있어요!")
        .supportedFamilies([.systemMedium])   // 가로형 위젯 only
    }
}

extension ConfigurationAppIntent {
    static var preview: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
}

#Preview(as: .systemMedium) {
    MentoryWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .preview)
}
