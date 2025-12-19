//
//  StatisticsBoardView.swift
//  Mentory
//
//  Created by SJS on 12/17/25.
//

import SwiftUI
import Values

struct StatisticsBoardView: View {

    @State private var board: StatisticsBoard

    init(board: StatisticsBoard) {
        _board = State(initialValue: board)
    }

    var body: some View {
        NavigationStack {
            Group {
                if board.state.isLoading {
                    ProgressView("통계를 불러오는 중입니다.")
                } else if let message = board.state.errorMessage {
                    ContentUnavailableView("불러오기 실패", systemImage: "exclamationmark.triangle", description: Text(message))
                } else if board.state.allRecords.isEmpty {
                    ContentUnavailableView("분석 결과가 없어요", systemImage: "chart.bar",
                                           description: Text("기록을 작성하고 분석을 완료하면 통계가 표시됩니다."))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            MonthHeader(
                                month: board.state.selectedMonth,
                                onPrev: { board.moveMonth(-1) },
                                onNext: { board.moveMonth(1) },
                                onPickMonth: { board.setMonth($0) },
                                onToday: { board.goToday() }
                            )

                            CalendarGrid(
                                month: board.state.selectedMonth,
                                selectedDate: board.state.selectedDate,
                                recordForDay: { board.record(for: $0) },
                                onSelect: { board.selectDate($0) }
                            )

                            if let selected = board.state.selectedDate,
                               let record = board.record(for: selected) {
                                SelectedDayCard(day: selected, record: record)
                            } else if let selected = board.state.selectedDate {
                                Text("\(selected.formatted(date: .abbreviated, time: .omitted)) 기록이 없어요")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("통계")
        }
        .onAppear { board.load() }
    }
}

private struct MonthHeader: View {
    let month: Date
    let onPrev: () -> Void
    let onNext: () -> Void
    let onPickMonth: (Date) -> Void
    let onToday: () -> Void

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPrev) { Image(systemName: "chevron.left") }

            DatePicker(
                "",
                selection: Binding(
                    get: { month },
                    set: { onPickMonth($0) }
                ),
                displayedComponents: [.date]
            )
            .labelsHidden()
            .datePickerStyle(.compact)

            Spacer()

            Button("오늘로 이동") { onToday() }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .disabled(isCurrentMonth)
                .opacity(isCurrentMonth ? 0.4 : 1.0)

            Button(action: onNext) { Image(systemName: "chevron.right") }
        }
    }
}

private struct CalendarGrid: View {
    let month: Date
    let selectedDate: Date?
    let recordForDay: (Date) -> RecordData?
    let onSelect: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdaySymbols = ["일","월","화","수","목","금","토"]

    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { w in
                    Text(w).font(.caption).foregroundStyle(.secondary)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonthGrid(month), id: \.self) { day in
                    DayCell(
                        day: day,
                        isCurrentMonth: calendar.isDate(day, equalTo: month, toGranularity: .month),
                        isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: day) } ?? false,
                        isToday: calendar.isDateInToday(day),
                        record: recordForDay(day),
                        onTap: { onSelect(day) }
                    )
                }
            }
        }
    }

    // 달력 그리드용 날짜 배열(앞/뒤 공백 포함)
    private func daysInMonthGrid(_ month: Date) -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) // 1=일

        var days: [Date] = []

        // 앞쪽 빈칸(이전 달 날짜로 채우기)
        let leading = firstWeekday - 1
        if leading > 0 {
            for i in stride(from: leading, to: 0, by: -1) {
                days.append(calendar.date(byAdding: .day, value: -i, to: startOfMonth)!)
            }
        }

        // 이번 달 날짜
        for d in range {
            days.append(calendar.date(byAdding: .day, value: d - 1, to: startOfMonth)!)
        }

        // 뒤쪽 채우기(7의 배수로)
        while days.count % 7 != 0 {
            days.append(calendar.date(byAdding: .day, value: 1, to: days.last!)!)
        }

        return days
    }
}

private struct DayCell: View {
    let day: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let isToday: Bool
    let record: RecordData?
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.subheadline)
                    .foregroundStyle(isCurrentMonth ? .primary : .secondary)

                // 기록이 있으면 감정 표시(일단 텍스트/점으로 MVP)
                if let record {
                    Text(record.emotion.rawValue)
                        .font(.caption2)
                        .lineLimit(1)
                } else {
                    Text(" ")
                        .font(.caption2)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.primary.opacity(0.08) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

private struct SelectedDayCard: View {
    let day: Date
    let record: RecordData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.formatted(date: .long, time: .omitted))
                .font(.headline)

            Text(record.emotion.rawValue)
                .font(.subheadline)

            Text(record.analyzedResult)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
