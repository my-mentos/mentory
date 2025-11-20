//
//  TodayBoardView.swift
//  Mentory
//
//  Created by JAY on 11/14/25.
//
import SwiftUI
import SwiftData


// MARK: View
struct TodayBoardView: View {
    // MARK: core
    @ObservedObject var todayBoard: TodayBoard
    @Query var allRecords: [MentoryRecord]
    @State private var isShowingRecordFormView = false

    @State private var isShowingInformationView = false
    
    init(_ todayBoard: TodayBoard) {
        self.todayBoard = todayBoard
    }
    
    
    // MARK: body
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 배경
            Color(.systemGray6)
                .ignoresSafeArea()
                .task {
                    await todayBoard.loadTodayRecords()
                    await todayBoard.fetchTodayString()
                }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 상단 타이틀 & 인포 버튼
                    HStack(alignment: .top) {
                        Text("기록")
                            .font(.system(size: 34, weight: .bold))
                        
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
                            Text("\(userName)님, 일기를 작성해보아요!")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text("\(userName)님 \(count)번째 기록하셨네요!")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.top, 16)
                    
                    // 작은 설명 텍스트

                    let userName = todayBoard.owner?.userName ?? "이름없음"
                    let totalCount = allRecords.count

                    if totalCount == 0 {
                        Text("\(userName)님, 일기를 작성해보아요!")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("\(userName)님 총 \(totalCount)건 기록하셨네요!")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                        // "오늘의 명언" 카드
                        if let todayString = todayBoard.todayString {
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
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.white)
                                    //.shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                            )
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                        }
                        
                        // 기분 기록 카드
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
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.blue)
                                    )
                            }
                            .fullScreenCover(isPresented: $isShowingRecordFormView) {
                                RecordFormView(todayBoard.recordForm!)
                            }
                            .padding(.horizontal, 32)
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white)
                            //.shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        )
                        
                        // 오늘의 행동 추천
                        VStack(alignment: .leading, spacing: 16) {
                            Text("오늘의 행동 추천?")
                                .font(.system(size: 16, weight: .semibold))
                            
                            VStack(spacing: 12) {
                                // 상단 프로그레스 바 영역
                                HStack {
                                    ZStack {
                                        Capsule()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 10)
                                        
                                        GeometryReader { geo in
                                            Capsule()
                                                .fill(Color.gray.opacity(0.6))
                                                .frame(width: geo.size.width * (7.0 / 9.0), height: 10)
                                        }
                                    }
                                    .frame(height: 10)
                                    
                                    Button {
                                        // 새로고침 액션
                                    } label: {
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                // 진행 텍스트
                                Text("7/9")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            
                            // 추천 리스트 카드
                            VStack(spacing: 12) {
                                ActionRow(checked: false, text: "Swift Concurrency 이해하기")
                                ActionRow(checked: true, text: "산책")
                                ActionRow(checked: false, text: "소금빵먹기")
                            }
                        }
                        .padding(.vertical, 18)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                            //.shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: todayBoard.todayString != nil)
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
