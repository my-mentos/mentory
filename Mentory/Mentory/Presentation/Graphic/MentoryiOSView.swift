//
//  ContentView.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//

import SwiftUI

struct MentoryiOSView: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if mentoryiOS.onboardingFinished {
                    TabView {
                        // 1) 기록 탭 (TodayBoard)
                        if let todayBoard = mentoryiOS.todayBoard {
                            TodayBoardView(todayBoardModel: todayBoard)
                                .tabItem {
                                    Image(systemName: "square.and.pencil")
                                    Text("기록")
                                }
                        } else {
                            Text("기록 화면을 준비 중입니다.")
                                .tabItem {
                                    Image(systemName: "square.and.pencil")
                                    Text("기록")
                                }
                        }
                        
                        // 2) 통계 탭 (아직 미구현, placeholder)
                        Text("통계 화면 준비 중")
                            .tabItem {
                                Image(systemName: "chart.xyaxis.line")
                                Text("통계")
                            }
                        
                        // 3) 설정 탭 (SettingBoardView)
                        Text("설정 화면 준비 중")
                            .tabItem {
                                Image(systemName: "gearshape")
                                Text("설정")
                            }
                        
                        // SettingBoard merge 후 밑에 코드로 변경
                        /*
                        if let settingBoard = mentoryiOS.settingBoard { //settingBoard가 Merger되기 전이라 오류가 발생함.
                            SettingBoardView(settingBoard: settingBoard) // 아직 merge가 진행되기 전이라 오류가 발생함.
                                .tabItem {
                                    Image(systemName: "gearshape")
                                    Text("설정")
                                }
                        } else {
                            Text("설정 화면을 준비 중입니다.")
                                .tabItem {
                                    Image(systemName: "gearshape")
                                    Text("설정")
                                }
                        }*/
                    }
                } else {
                    if let onBoarding = mentoryiOS.onboarding {
                        OnboardingView(onboardingModel: onBoarding)
                    } else {
                        ProgressView()
                    }
                }
            }.task {
                mentoryiOS.setUp()
                mentoryiOS.loadUserName()
            }
        }
    }
}

#Preview {
    MentoryiOSView()
}
