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
    
    
    // MARK: viewModel
    @State private var selectedTab: Tab = .record
    
    
    // MARK: body
    var body: some View {
        ZStack {
            if mentoryiOS.onboardingFinished {
                TabView(selection: $selectedTab) {
                    // 기록 탭
                    TodayBoardTab
                        .tabItem {
                            Image(systemName: "square.and.pencil")
                            Text("기록")
                        }
                        .tag(Tab.record)
                    
                    // 통계 탭
                    StaticTab
                        .tabItem {
                            Image(systemName: "chart.xyaxis.line")
                            Text("통계")
                        }
                        .tag(Tab.statistics)
                    
                    // 설정 탭
                    SettingTab
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("설정")
                        }
                        .tag(Tab.setting)
                }
                .onOpenURL { url in
                    print("딥링크 수신:", url)
                    
                    guard url.scheme == "mentory" else { return }
                    
                    if url.host == "record" {
                        selectedTab = .record
                    }
                }
                
            } else {
                OnboardingTab
            }
        }
        .task {
            await mentoryiOS.loadUserName()
            mentoryiOS.setUp()
        }
    }
    
    
    // MARK: value
    enum Tab {
        case record
        case statistics
        case setting
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
        StatisticsView()
    }
    
    @ViewBuilder
    private var SettingTab: some View {
        if let settingBoard = mentoryiOS.settingBoard {
            SettingBoardView(settingBoard: settingBoard, settingBoardViewModel: SettingBoardViewModel())
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
fileprivate struct MentoryiOSPreview: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        MentoryiOSView(mentoryiOS)
    }
}

#Preview {
    MentoryiOSPreview()
}
