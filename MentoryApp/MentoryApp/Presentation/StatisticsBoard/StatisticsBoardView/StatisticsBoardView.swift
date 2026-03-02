//
//  StatisticsBoardView.swift
//  Mentory
//
//  Created by SJS on 12/17/25.
//

import SwiftUI
import Values
import MentoryCore



//struct StatisticsBoardView: View {
//    
//    @State private var board: StatBoard
//    
//    init(board: StatBoard) {
//        _board = State(initialValue: board)
//    }
//    
//    var body: some View {
//        NavigationStack {
//            Group {
//                if board.state.isLoading {
//                    ProgressView("통계를 불러오는 중입니다.")
//                } else if let message = board.state.errorMessage {
//                    ContentUnavailableView("불러오기 실패", systemImage: "exclamationmark.triangle", description: Text(message))
//                } else if board.state.allRecords.isEmpty {
//                    ContentUnavailableView("분석 결과가 없어요", systemImage: "chart.bar",
//                                           description: Text("기록을 작성하고 분석을 완료하면 통계가 표시됩니다."))
//                } else {
//                    ScrollView {
//                        VStack(spacing: 16) {
//                            MonthHeader(
//                                month: board.state.selectedMonth,
//                                onPrev: { board.moveMonth(-1) },
//                                onNext: { board.moveMonth(1) },
//                                onPickMonth: { board.setMonth($0) },
//                                onToday: { board.goToday() }
//                            )
//                            
//                            CalendarGrid(
//                                month: board.state.selectedMonth,
//                                selectedDate: board.state.selectedDate,
//                                recordForDay: { board.record(for: $0) },
//                                onSelect: { board.selectDate($0) }
//                            )
//                            
//                            if let selected = board.state.selectedDate,
//                               let record = board.record(for: selected) {
//                                SelectedDayCard(day: selected, record: record)
//                            } else if let selected = board.state.selectedDate {
//                                Text("\(selected.formatted(date: .abbreviated, time: .omitted)) 기록이 없어요")
//                                    .font(.footnote)
//                                    .foregroundStyle(.secondary)
//                            }
//                        }
//                        .padding()
//                    }
//                }
//            }
//            .navigationTitle("통계")
//        }
//        .onAppear {
//            board.load()
//        }
//    }
//}
//
//private struct MonthHeader: View {
//    let month: Date
//    let onPrev: () -> Void
//    let onNext: () -> Void
//    let onPickMonth: (Date) -> Void
//    let onToday: () -> Void
//    
//    @State private var isShowingMonthPicker = false
//    @State private var tempYear: Int = 0
//    @State private var tempMonth: Int = 0
//    
//    private let calendar = Calendar.current
//    
//    private var isCurrentMonth: Bool {
//        Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month)
//    }
//    
//    private var monthFormatter: DateFormatter {
//        let f = DateFormatter()
//        f.locale = Locale(identifier: "ko_KR")
//        f.dateFormat = "yyyy. M."
//        return f
//    }
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Button(action: onPrev) {
//                Image(systemName: "chevron.left")
//            }
//            
//            Button {
//                let comps = calendar.dateComponents([.year, .month], from: month)
//                tempYear = comps.year ?? calendar.component(.year, from: Date())
//                tempMonth = comps.month ?? calendar.component(.month, from: Date())
//                isShowingMonthPicker = true
//            } label: {
//                Text(monthFormatter.string(from: month))
//                    .font(.headline.weight(.semibold))
//                    .foregroundStyle(.primary)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(.thinMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
//            }
//            Spacer()
//            
//            Button("오늘로 이동") {
//                onToday()
//            }
//            .font(.subheadline.weight(.semibold))
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(.thinMaterial)
//            .clipShape(Capsule())
//            .disabled(isCurrentMonth)
//            .opacity(isCurrentMonth ? 0.4 : 1.0)
//            
//            Button(action: onNext) {
//                Image(systemName: "chevron.right")
//            }
//        }
//        .sheet(isPresented: $isShowingMonthPicker) {
//            MonthPickerSheet(
//                tempYear: $tempYear,
//                tempMonth: $tempMonth,
//                onCancel: { isShowingMonthPicker = false },
//                onDone: {
//                    if let date = calendar.date(from: DateComponents(year: tempYear, month: tempMonth, day: 1)) {
//                        onPickMonth(date)
//                    }
//                    isShowingMonthPicker = false
//                }
//            )
//            .presentationDetents([.height(280)])
//        }
//    }
//}
//
//private struct MonthPickerSheet: View {
//    @Binding var tempYear: Int
//    @Binding var tempMonth: Int
//    let onCancel: () -> Void
//    let onDone: () -> Void
//    
//    @State private var yearCenter: Int = 0
//    @State private var yearIndex: Int = 0
//    @State private var monthIndex: Int = 0
//    
//    private let yearSpan: Int = 200
//    private let monthItems: [Int] = Array(1...12) + Array(1...12) + Array(1...12)
//    
//    private var yearItems: [Int] {
//        let half = yearSpan / 2
//        return Array((yearCenter - half)...(yearCenter + half))
//    }
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            HStack {
//                Button("취소", action: onCancel)
//                Spacer()
//                Button("선택", action: onDone)
//            }
//            .font(.headline)
//            
//            HStack {
//                Picker("년도", selection: $yearIndex) {
//                    ForEach(Array(yearItems.enumerated()), id: \.offset) { index, year in
//                        Text(verbatim: "\(year)년").tag(index)
//                    }
//                }
//                .pickerStyle(.wheel)
//                
//                Picker("월", selection: $monthIndex) {
//                    ForEach(Array(monthItems.enumerated()), id: \.offset) { index, month in
//                        Text("\(month)월").tag(index)
//                    }
//                }
//                .pickerStyle(.wheel)
//            }
//        }
//        .padding()
//        .onAppear {
//            yearCenter = tempYear
//            yearIndex = yearSpan / 2
//            monthIndex = 12 + (tempMonth - 1)
//        }
//        .onChange(of: yearIndex) { _, newValue in
//            guard yearItems.indices.contains(newValue) else { return }
//            tempYear = yearItems[newValue]
//            
//            if newValue < 20 || newValue > yearItems.count - 21 {
//                yearCenter = tempYear
//                DispatchQueue.main.async {
//                    yearIndex = yearSpan / 2
//                }
//            }
//        }
//        .onChange(of: monthIndex) { _, newValue in
//            guard monthItems.indices.contains(newValue) else { return }
//            tempMonth = monthItems[newValue]
//            
//            if newValue < 6 {
//                monthIndex += 12
//            } else if newValue > monthItems.count - 7 {
//                monthIndex -= 12
//            }
//        }
//    }
//}
//
//private struct CalendarGrid: View {
//    let month: Date
//    let selectedDate: Date?
//    let recordForDay: (Date) -> RecordData?
//    let onSelect: (Date) -> Void
//    
//    private let calendar = Calendar.current
//    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
//    private let weekdaySymbols = ["일","월","화","수","목","금","토"]
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            LazyVGrid(columns: columns, spacing: 8) {
//                ForEach(weekdaySymbols, id: \.self) { w in
//                    Text(w).font(.footnote).foregroundStyle(.secondary)
//                }
//            }
//            
//            LazyVGrid(columns: columns, spacing: 8) {
//                ForEach(daysInMonthGrid(month), id: \.self) { day in
//                    DayCell(
//                        day: day,
//                        isCurrentMonth: calendar.isDate(day, equalTo: month, toGranularity: .month),
//                        isSelected: selectedDate.map {
//                            calendar.isDate($0, inSameDayAs: day)
//                        } ?? false,
//                        record: recordForDay(day),
//                        onTap: { onSelect(day) }
//                    )
//                }
//            }
//        }
//    }
//    
//    private func daysInMonthGrid(_ month: Date) -> [Date] {
//        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
//        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
//        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
//        
//        var days: [Date] = []
//        
//        let leading = firstWeekday - 1
//        if leading > 0 {
//            for i in stride(from: leading, to: 0, by: -1) {
//                days.append(calendar.date(byAdding: .day, value: -i, to: startOfMonth)!)
//            }
//        }
//        
//        for d in range {
//            days.append(calendar.date(byAdding: .day, value: d - 1, to: startOfMonth)!)
//        }
//        
//        while days.count % 7 != 0 {
//            days.append(calendar.date(byAdding: .day, value: 1, to: days.last!)!)
//        }
//        
//        return days
//    }
//}
//
//private struct DayCell: View {
//    let day: Date
//    let isCurrentMonth: Bool
//    let isSelected: Bool
//    let record: RecordData?
//    let onTap: () -> Void
//    
//    private let calendar = Calendar.current
//    
//    var body: some View {
//        Button(action: onTap) {
//            VStack(spacing: 4) {
//                Text("\(calendar.component(.day, from: day))")
//                    .font(.callout)
//                    .foregroundStyle(isCurrentMonth ? .primary : .secondary)
//                
//                if let record {
//                    Text(record.emotion.emoji)
//                        .font(.headline)
//                        .lineLimit(1)
//                } else {
//                    Text(" ")
//                        .font(.headline)
//                }
//            }
//            .frame(height: 48)
//            .frame(maxWidth: .infinity)
//            .background(isSelected ? Color.primary.opacity(0.08) : Color.clear)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//private struct SelectedDayCard: View {
//    let day: Date
//    let record: RecordData
//    
//    var body: some View {
//        VStack(alignment: .center, spacing: 10) {
//            Text(day.formatted(date: .long, time: .omitted))
//                .font(.headline)
//                .foregroundStyle(.secondary)
//            
//            Text(record.emotion.emoji)
//                .font(.system(size: 44))
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 20)
//        .background(.thinMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 18))
//    }
//}
