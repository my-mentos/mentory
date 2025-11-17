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
                    if let todayBoard = mentoryiOS.todayBoard {
                        TodayBoardView(todayBoardModel: todayBoard)
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
