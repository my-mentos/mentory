//
//  TodayBoardView.swift
//  Mentory
//
//  Created by JAY on 11/14/25.
//
import SwiftUI


@MainActor @Observable
final class TodayBoardViewModel {
    // MARK: core
    
    
    // MARK: state
    
    
    // MARK: action
    
    
    // MARK: value
}


// MARK: View
struct TodayBoardView: View {
    // MARK: model
    @ObservedObject var todayBoard: TodayBoard
    
    // MARK: viewModel
    @State private var isShowingRecordFormView = false
    @State private var isShowingInformationView = false
    @State private var selections = [false, false, false]
    @State private var actionRowEmpty = false
    var progress: Double {
        Double(selections.filter { $0 }.count) / 3.0
    }
    
    
    init(_ todayBoard: TodayBoard) {
        self.todayBoard = todayBoard
    }
    
    
    // MARK: body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                // 배경
                Color(.systemGray6)
                    .ignoresSafeArea()
                    .task {
                        await todayBoard.fetchTodayString()
                    }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 상단 타이틀
                        HStack(alignment: .top) {
                            Text("기록")
                                .font(.system(size: 34, weight: .bold))
                            
                            Spacer()
                        }
                        .padding(.top, 16)
                        
                        // 작은 설명 텍스트
                        
                        let userName = todayBoard.owner?.userName ?? "이름없음"
                        let count = todayBoard.records.count
                        
                        if count == 0 {
                            Text("\(userName)님, 일기를 작성해보세요!")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text("\(userName)님 \(count)번째 기록하셨네요!")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        // "오늘의 명언" 카드
                        if let todayString = todayBoard.todayString {
                            LiquidGlassCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("오늘의 명언")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Text(todayString)
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
                        
                        // 기분 기록 카드
                        LiquidGlassCard {
                            VStack(spacing: 16) {
                                // 이미지
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemTeal).opacity(0.5))
                                        .frame(width: 170, height: 170)
                                    
                                    // 실제 이미지를 사용한다면 아래에 넣으면 됨
                                    // Image("yourImageName")
                                    //   .resizable()
                                    //   .scaledToFit()
                                    //   .frame(width: 170, height: 170)
                                    Text("이미지")
                                        .foregroundColor(.white)
                                }
                                
                                Text("오늘 기분을 기록해볼까요?")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Button {
                                    // 기록하러가기 액션
                                    isShowingRecordFormView.toggle()
                                } label: {
                                    Text("기록하러가기")
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
                                .fullScreenCover(isPresented: $isShowingRecordFormView) {
                                    RecordFormView(todayBoard.recordForm!)
                                }
                                .padding(.horizontal, 32)
                            }
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity)
                        }
                        
                        // 오늘의 행동 추천
                        
                        // 오늘의 행동 추천 - LiquidGlass 스타일 개선
                        LiquidGlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    // 제목
                                    Text("오늘은 이런 행동 어떨까요?")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    
                                    Text("7/9")
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
                                
                                
                                // MARK: - Action Items
                                if todayBoard.actionKeyWordItems.isEmpty {
                                    ActionRow(checked: $actionRowEmpty, text: "기록을 남기고 추천행동을 완료해보세요!")
                                } else {
                                    VStack(spacing: 12) {
                                        ActionRow(checked: $selections[0], text: "Swift Concurrency 이해하기")
                                        ActionRow(checked: $selections[1], text: "산책")
                                        ActionRow(checked: $selections[2], text: "소금빵 먹기")
                                    }
                                    .padding(.top, 20)
                                }
                            }
                            .padding(.vertical, 22)
                            .padding(.horizontal, 18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8),
                               value: todayBoard.todayString != nil)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingInformationView = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingInformationView) {
            NavigationStack {
                InformationView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("닫기") {
                                isShowingInformationView = false
                            }
                        }
                    }
                }
            }
        .task {
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
