//
//  RecordFormLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/24/25.
//
import SwiftUI


// MARK: Layout
struct RecordFormLayout<TopBar: View, Main: View, BottomBar: View>: View {
    @ViewBuilder let topBar: () -> TopBar
    @ViewBuilder let main: () -> Main
    @ViewBuilder let bottomBar: () -> BottomBar
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                
                self.topBar()
                
                ScrollView {
                    VStack(spacing: 16) {
                        self.main()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                }
                Spacer()
            }
            VStack {
                Spacer()
                self.bottomBar()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
