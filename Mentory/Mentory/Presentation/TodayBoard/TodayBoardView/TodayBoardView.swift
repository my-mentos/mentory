//
//  TodayBoardView.swift
//  Mentory
//
//  Created by JAY on 11/14/25.
//
import SwiftUI
import WebKit
import Combine


// MARK: View
struct TodayBoardView: View {
    // MARK: model
    @ObservedObject var todayBoard: TodayBoard
    @ObservedObject var mentoryiOS: MentoryiOS
    init(_ todayBoard: TodayBoard) {
        self.todayBoard = todayBoard
        self.mentoryiOS = todayBoard.owner!
    }
    
    
    // MARK: viewModel
    @State private var isShowingInformationView = false
    @State private var selections = [false, false, false]
    var progress: Double {
        Double(selections.filter { $0 }.count) / 3.0
    }
    @State private var actionRowEmpty = false
    
    
    // MARK: body
    var body: some View {
        TodayBoardLayout {
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
                title: "오늘의 명언",
                content: todayBoard.todayString
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
            SuggestionCard {
                if todayBoard.actionKeyWordItems.isEmpty {
                    ActionRow(checked: $actionRowEmpty, text: "기록을 남기고 추천행동을 완료해보세요!")
                } else {
                    VStack(spacing: 12) {
                        // 예시
//                        ActionRow(checked: $selections[0], text: "Swift Concurrency 이해하기")
//                        ActionRow(checked: $selections[1], text: "산책")
//                        ActionRow(checked: $selections[2], text: "소금빵 먹기")

                        // 동적으로 행동 추천 생성
                        ForEach(todayBoard.actionKeyWordItems.indices, id: \.self) { index in
                            ActionRow(
                                checked: Binding(
                                    get: { todayBoard.actionKeyWordItems[index].1 },
                                    set: { newValue in
                                        todayBoard.actionKeyWordItems[index].1 = newValue
                                        // 체크 상태 변경 시 DB에 실시간 업데이트
                                        Task {
                                            await todayBoard.updateActionCompletion()
                                        }
                                    }
                                ),
                                text: todayBoard.actionKeyWordItems[index].0
                            )
                        }
                    }
                    .padding(.top, 20)
                }
            }
            
        } toolbarContent: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingInformationView = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $isShowingInformationView) {
            WebView(url: todayBoard.owner!.informationURL)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("닫기") {
                                isShowingInformationView = false
                            }
                        }
                    }
        }
        .task {
            await todayBoard.fetchTodayString()
            await todayBoard.loadTodayRecords()
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
            Text("기록")
                .font(.system(size: 34, weight: .bold))
            
            Spacer()
        }
        .padding(.top, 16)
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
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text("\(userName)님 \(recordCount)번째 기록하셨네요!")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }.animation(
            .spring(response: 0.6, dampingFraction: 0.8),
            value: todayBoard.todayString != nil)
    }
}

fileprivate struct PopupCard: View {
    let title: String
    let content: String?
    init(title: String, content: String? = nil) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        if let content {
            LiquidGlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(content)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
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
                // 이미지
                ZStack {
                    Image(imageName)
                       .resizable()
                       .scaledToFit()
                       .frame(width: 170, height: 170)
                }
                
                Text(content)
                    .font(.system(size: 16, weight: .medium))
                
                Button {
                    todayBoard.setUpForm()
                } label: {
                    Text(self.navLabel)
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(
                            color: Color.blue.opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                }
                .padding(.horizontal, 32)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .fullScreenCover(isPresented: $showFullScreenCover) {
                if let recordForm = todayBoard.recordForm {
                    navDestination(recordForm)
                }
            }
        }
        .task {
            let stream = todayBoard.$recordForm.values
                .map { $0 != nil }
            
            for await isPresent in stream {
                self.showFullScreenCover = isPresent
            }
            
        }
    }
}

fileprivate struct SuggestionCard<Content: View>: View {
    let header: String = "오늘은 이런 행동 어떨까요?"
    let counter: String = "7/9"
    let progress: Double = 7/9
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // 제목
                    Text(header)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    
                    Text(counter)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(alignment: .trailing)
                }
                // MARK: - Progress Section
                HStack {
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
                                .frame(width: geo.size.width * progress)
                                .shadow(color: .purple.opacity(0.3), radius: 3, x: 0, y: 1)
                        }
                    }
                    .frame(height: 10)
                    Button {
                        // 새로고침 액션
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(6)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 6)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                
                self.content
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}




