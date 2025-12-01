//
//  TodayBoardView.swift
//  Mentory
//
//  Created by JAY on 11/14/25.
//
import SwiftUI
import WebKit
import Combine
import Values


// MARK: View
struct TodayBoardView: View {
    // MARK: model
    @ObservedObject var todayBoard: TodayBoard
    @ObservedObject var mentoryiOS: MentoryiOS
    
    init(_ todayBoard: TodayBoard) {
        self.todayBoard = todayBoard
        self.mentoryiOS = todayBoard.owner!
    }
    
    // MARK: body
    var body: some View {
        TodayBoardLayout(
            navDestination: { WebView(url: todayBoard.owner!.informationURL) }
        )
        {
            // 상단 타이틀
            Title("기록")
            
            // 환영 인사 헤더
            GreetingHeader(
                todayBoard: todayBoard,
                userName: mentoryiOS.userName ?? "익명",
                recordCount: todayBoard.records.count
            )
            
            // "오늘의 명언" 카드
            PopupCard(
                title: todayBoard.mentorMessage?.characterType.title ?? "오늘의 멘토리 조언을 준비하고 있어요",
                content: todayBoard.mentorMessage?.message ?? "잠시 후 당신을 위한 멘토리 메시지가 도착해요\n오늘은 냉철이일까요, 구름이일까요?\n조금만 기다려 주세요"
            )
            
            // 기분 기록 카드
            RecordStatCard(
                todayBoard: todayBoard,
                imageName: "greeting",
                content: "오늘 기분을 기록해볼까요?",
                navLabel: "기록하러 가기",
                navDestination: { recordForm in
                    RecordFormView(recordForm: recordForm)
                }
            )
            
            // 행동 추천 카드
            SuggestionCard(
                todayBoard: todayBoard,
                header: "오늘은 이런 행동 어떨까요?",
                actionRows: SuggestionActionRows(todayBoard: todayBoard)
            )
        }
        // 로드 시 2개의 비동기 작업 실행
        .task {
            // 오늘의 기록 불러오기
            await todayBoard.loadTodayRecords()
        }
        .task {
            await todayBoard.loadTodayMentorMessageTest()
        }
    }
}



// MARK: Preview
fileprivate struct TodayBoardPreview: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard {
            TodayBoardView(todayBoard)
        } else {
            ProgressView("프리뷰 준비 중")
                .task {
                    mentoryiOS.setUp()
                    
                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김철수"
                    onboarding.next()
                }
        }
    }
}

#Preview {
    TodayBoardPreview()
}



// MARK: Component
fileprivate struct Title: View {
    let title: String
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.top, 0)
    }
}

fileprivate struct GreetingHeader: View {
    @ObservedObject var todayBoard: TodayBoard
    let userName: String
    let recordCount: Int
    
    var body: some View {
        // 작은 설명 텍스트
        Group{
            if recordCount == 0 {
                Text("\(userName)님, 일기를 작성해보세요!")
            } else {
                Text("\(userName)님 \(recordCount)번째 기록하셨네요!")
            }
        }
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8),
            value: todayBoard.mentorMessage?.message != nil)
    }
}

fileprivate struct PopupCard: View {
    let title: String
    let content: String?
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        if let content {
            LiquidGlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text(content)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }
}

fileprivate struct RecordStatCard<Content: View>: View {
    @ObservedObject var todayBoard: TodayBoard
    @State var showFullScreenCover: Bool = false
    
    let imageName: String
    let content: String
    let navLabel: String
    @ViewBuilder let navDestination: (RecordForm) -> Content
    
    
    var body: some View {
        LiquidGlassCard {
            VStack(spacing: 16) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 170)
                
                Text(content)
                    .foregroundStyle(.primary)
                    .font(.system(size: 16, weight: .medium))
                
                Button {
                    todayBoard.setUpForm()
                } label: {
                    Text(navLabel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                        )
                }
                .padding(.horizontal, 32)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
        }
        .task {
            for await isPresent in todayBoard.$recordForm.values.map({ $0 != nil }) {
                self.showFullScreenCover = isPresent
            }
        }
        .fullScreenCover(isPresented: $showFullScreenCover) {
            if let form = todayBoard.recordForm {
                navDestination(form)
            }
        }
    }
}

fileprivate struct SuggestionCard<ActionRows: View>: View {
    @ObservedObject var todayBoard: TodayBoard
    let header: String
    let actionRows: ActionRows
    
    init(todayBoard: TodayBoard, header: String, actionRows: ActionRows) {
        self.todayBoard = todayBoard
        self.header = header
        self.actionRows = actionRows
    }
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(header)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(todayBoard.getIndicator())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                
                ProgressSection
                
                actionRows
                    .padding(.top, 20)
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 18)
        }
    }
    
    private var ProgressSection: some View {
        HStack {
            ZStack {
                Capsule()
                    .fill(Color.mentoryProgressTrack)
                    .frame(height: 10)
                
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
                        .frame(width: geo.size.width * todayBoard.getProgress())
                        .animation(.spring(response: 0.6,
                                           dampingFraction: 0.7), value: todayBoard.getProgress())
                }
            }
            .frame(height: 10)
            
            Button {
                // TODO: 새로고침
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(6)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(Color.mentorySubCard.opacity(0.5),
                    in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.mentoryBorder.opacity(0.4), lineWidth: 1)
        )
    }
}

fileprivate struct SuggestionActionRows: View {
    @ObservedObject var todayBoard: TodayBoard
    @State private var actionRowEmpty = false
    
    init(todayBoard: TodayBoard) {
        self.todayBoard = todayBoard
    }
    
    var body: some View {
        if todayBoard.actionKeyWordItems.isEmpty {
            ActionRow(checked: $actionRowEmpty, text: "기록을 남기고 추천행동을 완료해보세요!")
        } else {
            VStack(spacing: 12) {
                ForEach(todayBoard.actionKeyWordItems.indices, id: \.self) { index in
                    ActionRow(
                        checked: Binding(
                            get: { todayBoard.actionKeyWordItems[index].1 },
                            set: { newValue in
                                todayBoard.actionKeyWordItems[index].1 = newValue
                                // 체크 상태 변경 시 DB에 실시간 업데이트
                                Task {
                                    await todayBoard.updateActionCompletion()
                                    await todayBoard.loadTodayRecords()
                                }
                            }
                        ),
                        text: todayBoard.actionKeyWordItems[index].0
                    )
                }
            }
        }
    }
}

// MARK: - DateSelectionSheet
fileprivate struct DateSelectionSheet: View {
    @ObservedObject var todayBoard: TodayBoard
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // 헤더
            VStack(spacing: 8) {
                Text("어느 날의 일기를 쓸까요?")
                    .font(.system(size: 24, weight: .bold))
                
                Text("작성 가능한 날짜를 선택해주세요.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text("일기는 최대 이틀 전까지의 날짜만 작성할 수 있어요.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.top, 32)
            
            // 날짜 선택 버튼들 또는 완료 메시지
            if todayBoard.recordForms.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .padding(.top, 32)
                    
                    Text("모든 일기를 작성했어요!")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("오늘, 어제, 그제의 일기를\n모두 작성하셨습니다.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("확인")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(
                                color: Color.blue.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                
                Spacer()
            } else {
                VStack(spacing: 12) {
                    ForEach(todayBoard.recordForms) { recordForm in
                        DateButton(
                            date: recordForm.targetDate,
                            action: {
                                // recordForm 설정
                                todayBoard.recordForm = recordForm
                                // Sheet 닫기
                                dismiss()
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

fileprivate struct DateButton: View {
    let date: RecordDate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(dateDescription(for: date))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func dateDescription(for recordDate: RecordDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일 (E)"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: recordDate.toDate())
    }
}
