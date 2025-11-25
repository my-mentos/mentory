//
//  TodayBoardLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/23/25.
//
import Foundation
import SwiftUI
import WebKit


// MARK: Layout
struct TodayBoardLayout<Content: View, navDestination: View>: View {
    @ViewBuilder let navDestination: () -> navDestination
    @ViewBuilder let content: () -> Content

    @State private var isShowingInformationView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GrayBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        self.content()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // action을 인자로 받도록
                        isShowingInformationView = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $isShowingInformationView) {
                // 웹 뷰 전체를 인자로 받도록
                self.navDestination()
            }
        }
    }
}


// MARK: Component
fileprivate struct GrayBackground: View {
    var body: some View {
        Color(.systemGray6)
            .ignoresSafeArea()
    }
}
