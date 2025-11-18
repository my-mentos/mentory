//
//  ContentView.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//
import SwiftUI


// MARK: View
struct MentoryiOSView: View {
    // MARK: model
    @ObservedObject var mentoryiOS: MentoryiOS
    init(_ mentoryiOS: MentoryiOS) {
        self.mentoryiOS = mentoryiOS
    }
    
    
    // MARK: body
    var body: some View {
        NavigationStack {
            ZStack {
                if mentoryiOS.onboardingFinished {
                    TabView {
                        // 기록 탭
                        TodayBoardTab
                            .tabItem {
                                Image(systemName: "square.and.pencil")
                                Text("기록")
                            }
                        
                        // 통계 탭
                        StaticTab
                            .tabItem {
                                Image(systemName: "chart.xyaxis.line")
                                Text("통계")
                            }
                        
                        // 설정 탭
                        SettingTab
                            .tabItem {
                                Image(systemName: "gearshape")
                                Text("설정")
                            }
                    }
                } else {
                    OnboardingTab
                }
            }.task {
                mentoryiOS.setUp()
                await mentoryiOS.loadUserName()
            }
        }
    }
    
    
    // MARK: component
    @ViewBuilder
    private var TodayBoardTab: some View {
        if let todayBoard = mentoryiOS.todayBoard {
            TodayBoardView(todayBoard)
        } else {
            Text("기록 화면을 준비 중입니다.")
        }
    }
    
    @ViewBuilder
    private var StaticTab: some View {
        Text("통계 화면 준비 중")
    }
    
    @ViewBuilder
    private var SettingTab: some View {
        if let settingBoard = mentoryiOS.settingBoard {
            SettingBoardView(settingBoard: settingBoard)
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
        }
    }
    
    @ViewBuilder
    private var OnboardingTab: some View {
        if let onBoarding = mentoryiOS.onboarding {
            OnboardingView(onBoarding)
        } else {
            ProgressView()
        }
    }
}


// MARK: Preview
#Preview {
    MentoryiOSView(.init())
}
