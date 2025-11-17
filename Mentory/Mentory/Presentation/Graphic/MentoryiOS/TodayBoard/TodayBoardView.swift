//
//  TodayBoardView.swift
//  Mentory
//
//  Created by JAY on 11/14/25.
//

import SwiftUI

struct TodayBoardView: View {
    @ObservedObject var todayBoardModel: TodayBoard
    @State private var isShowingRecordForm = false
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 배경
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 상단 타이틀 & 인포 버튼
                    HStack(alignment: .top) {
                        Text("기록")
                            .font(.system(size: 34, weight: .bold))
                        
                        Spacer()
                        
                        Button {
                            // info 버튼 액션
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .shadow(radius: 3)
                                    .frame(width: 36, height: 36)
                                
                                Text("i")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.top, 16)
                    
                    // 작은 설명 텍스트
                    
                    let userName = todayBoardModel.owner?.userName ?? "이름없음"
                    let count = todayBoardModel.records.count
                    
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
                    
                    // "오늘의 명언" 버튼
                    VStack(spacing: 16) {
                        Text("오늘의 명언")
                    }.padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white)
                            //.shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        )
                    
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
                        
                        Text("오늘 기분을 기록해볼까요??")
                            .font(.system(size: 16, weight: .medium))
                        
                        Button {
                            // 기록하러가기 액션
                            isShowingRecordForm.toggle()
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
                        .fullScreenCover(isPresented: $isShowingRecordForm) {
                            RecordFormView(recordFormModel: todayBoardModel.recordForm!)                                }
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
            }
        }
    }
}

struct ActionRow: View {
    var checked: Bool
    var text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
            } else {
                // 체크 없을 때 간격 맞추기용
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 18, height: 18)
            }
            
            Text(text.isEmpty ? " " : text)
                .font(.system(size: 16))
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
        )
    }
}

#Preview {
    let mentoryiOS = MentoryiOS()
    return TodayBoardView(todayBoardModel: mentoryiOS.todayBoard!)
}
