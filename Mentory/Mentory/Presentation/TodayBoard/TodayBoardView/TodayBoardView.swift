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
                userName: mentoryiOS.userName ?? "익명"
            )
            
            // 멘토리메세지 카드
            MessageView(mentorMessage: todayBoard.mentorMessage)
            
            // 기분 기록 카드
            RecordStatCard(
                todayBoard: todayBoard,
                imageName: "greeting",
                content: "오늘 기분을 기록해볼까요?",
                navLabel: "기록하러 가기",
                navDestination: { recordForm in
                    RecordContainerView(recordForm: recordForm)
                }
            )
            
            // 행동 추천 카드
            SuggestionCard(
                todayBoard: todayBoard,
                header: todayBoard.suggestions.isEmpty ? "기록을 남기고 추천 행동을 완료해보세요! " :"오늘은 이런 행동 어떨까요?",
                actionRows: SuggestionActionRows(todayBoard: todayBoard)
            )
        }
        .task {
            await todayBoard.setUpMentorMessage()
        }
        .task {
            // WatchConnectivity 설정
            let watchManager = WatchConnectivityManager.shared
            
            let handlers = WatchConnectivityManager.HandlerSet {
                todoText, isCompleted in
                Task { @MainActor in
                    await todayBoard.handleWatchTodoCompletion(
                        todoText: todoText,
                        isCompleted: isCompleted
                    )
                    await todayBoard.fetchEarnedBadges()
                }
            }
            watchManager.handlers = handlers
            
            await watchManager.setUp()
        }
    }
}



// MARK: Preview
fileprivate struct TodayBoardPreview: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard {
            TodayBoardView(
                todayBoard: todayBoard,
                mentoryiOS: todayBoard.owner!
            )
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

struct MessageView: View {
    let mentorMessage: MentorMessage?
    
    var body: some View {
        if let mentorMessage {
            MentorMessageView(mentorMessage: mentorMessage)
        } else {
            MentorMessageDefaultView()
        }
    }
}

struct MentorMessageDefaultView: View {
    var body: some View {
        PopupCard(
            image: nil,
            defaultImage: "greeting",
            title: nil,
            defaultTitle: "오늘의 멘토리 조언을 준비하고 있어요",
            content: nil,
            defaultContent: "잠시 후 당신을 위한 멘토리 메시지가 도착해요\n오늘은 냉철이일까요, 구름이일까요?\n조금만 기다려 주세요"
        )
    }
}

fileprivate struct GreetingHeader: View {
    @ObservedObject var todayBoard: TodayBoard
    let userName: String
    
    var body: some View {
        // 작은 설명 텍스트
        Group{
            if let recordCount = todayBoard.recordCount {
                if recordCount == 0 {
                    Text("\(userName)님, 일기를 작성해보세요!")
                } else {
                    Text("\(userName)님 \(recordCount)번째 기록하셨네요!")
                }
            } else {
                EmptyView()
            }
        }
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8),
            value: todayBoard.mentorMessage?.content != nil)
        .task {
            await todayBoard.fetchUserRecordCoount()
        }
    }
}

fileprivate struct RecordStatCard<Content: View>: View {
    @ObservedObject var todayBoard: TodayBoard
    @State var showFullScreenCover: Bool = false
    @State var showDateSelectionSheet: Bool = false
    
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
                    Task {
                        await todayBoard.setUpRecordForms()
                        showDateSelectionSheet = true
                    }
                } label: {
                    Text(navLabel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.mentoryAccentPrimary, Color.mentoryAccentPrimary.opacity(0.8)],
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
            await todayBoard.setUpRecordForms()
        }
        .task {
            let stream = todayBoard.$recordFormSelection.values
                .map { recordFormState in recordFormState != nil }
            
            for await isPresent in stream {
                self.showFullScreenCover = isPresent
            }
        }
        
        // 날짜 선택 Sheet (반쯤 올라옴)
        .sheet(isPresented: $showDateSelectionSheet) {
            DateSelectionSheet(todayBoard: todayBoard)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showFullScreenCover) {
            if let form = todayBoard.recordFormSelection {
                navDestination(form)
                
            }
        }
    }
}

fileprivate struct SuggestionCard<ActionRows: View>: View {
    @ObservedObject var todayBoard: TodayBoard
    let header: String
    let actionRows: ActionRows
    
    @State private var isFlipped = false
    @State private var initialBadgeCount: Int = 0
    
    init(todayBoard: TodayBoard, header: String, actionRows: ActionRows) {
        self.todayBoard = todayBoard
        self.header = header
        self.actionRows = actionRows
    }
    
    private var hasNewBadge: Bool {
        todayBoard.earnedBadges.count > initialBadgeCount
    }
    
    var body: some View {
        Group {
            if !isFlipped {
                // 앞면: Suggestion 리스트
                LiquidGlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Header
                        ProgressBar
                        actionRows
                            .padding(.top, 0)
                    }
                    .padding(.vertical, 22)
                    .padding(.horizontal, 18)
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            } else {
                // 뒷면: Badge 그리드
                LiquidGlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("획득한 뱃지")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isFlipped.toggle()
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16))
                                    .foregroundColor(.mentoryAccentPrimary)
                            }
                        }
                        
                        BadgeGridView(
                            earnedBadges: todayBoard.earnedBadges,
                            completedCount: todayBoard.completedSuggestionsCount
                        )
                    }
                    .padding(.vertical, 22)
                    .padding(.horizontal, 18)
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
        .task {
            await todayBoard.fetchEarnedBadges()
            // 처음 로드 시 현재 뱃지 개수를 기록
            if initialBadgeCount == 0 {
                initialBadgeCount = todayBoard.earnedBadges.count
            }
        }
        .task {
            await todayBoard.loadSuggestions()
            // Watch로 전송
            await todayBoard.sendSuggestionsToWatch()
        }
        .task(id: isFlipped) {
            // 뱃지 화면을 열면 현재 뱃지 개수로 업데이트 (dot 제거)
            if isFlipped == true {
                initialBadgeCount = todayBoard.earnedBadges.count
            }
        }
    }
    
    private var Header: some View {
        HStack {
            Text(header)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 16))
                        .foregroundColor(todayBoard.earnedBadges.isEmpty ? .gray.opacity(0.5) : .mentoryAccentPrimary)
                    
                    // 새 뱃지 알림 dot
                    if hasNewBadge {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
    }
    
    private var ProgressBar: some View {
        HStack {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // 배경 캡슐
                    Capsule()
                        .fill(Color.mentoryProgressTrack)
                        .frame(height: 10)
                    
                    // 상태 캡슐
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
                        .frame(
                            width: geo.size.width * todayBoard.suggestionProgress,
                            height: 10
                        )
                        .animation(.spring(), value: todayBoard.suggestionProgress)
                }
                .frame(height: 10)
            }
            Text(todayBoard.getSuggestionIndicator())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
    }
}

fileprivate struct SuggestionActionRows: View {
    @ObservedObject var todayBoard: TodayBoard
    
    init(todayBoard: TodayBoard) {
        self.todayBoard = todayBoard
    }
    
    var body: some View {
        ForEach(todayBoard.suggestions, id: \.self.id) { suggestion in
            SuggestionView(suggestion: suggestion)
            
        }
    }
}

// MARK: - DateSelectionSheet
fileprivate struct DateSelectionSheet: View {
    @ObservedObject var todayBoard: TodayBoard
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                // 제목 및 설명 텍스트
                VStack(spacing: 8) {
                    Text("어느 날의 일기를 쓸까요?")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("작성 가능한 날짜를 선택해주세요.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("일기는 최대 이틀 전까지의 날짜만 작성할 수 있어요.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
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
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("확인")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.mentoryAccentPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.mentorySubCard)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 16)
                    }
                    
                    Spacer()
                } else {
                    VStack(spacing: 12) {
                        ForEach(todayBoard.recordForms) { recordForm in
                            DateButton(
                                recordForm: recordForm,
                                date: recordForm.targetDate,
                                action: {
                                    // recordForm 설정
                                    todayBoard.recordFormSelection = recordForm
                                    // Sheet 닫기
                                    dismiss()
                                }
                            )
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .presentationDetents([.height(450)])
    }
}

fileprivate struct DateButton: View {
    @ObservedObject var recordForm: RecordForm
    let date: MentoryDate
    let action: () -> Void
    
    var body: some View {
        Button {
            if !recordForm.isDisabled {
                action()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date.relativeDay(from: .now).rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(date.formatted())
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
            .opacity(recordForm.isDisabled ? 0.4 : 1.0) // 시각적 피드백
        }
        .task {
            await recordForm.checkDisability()
        }
    }
}
