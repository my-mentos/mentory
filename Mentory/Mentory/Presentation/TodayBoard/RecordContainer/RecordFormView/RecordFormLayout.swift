//
//  RecordFormLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/24/25.
//
import SwiftUI
import UIKit


// MARK: Layout
struct RecordFormLayout<TodayDate: View, Main: View, BottomBar: View>: View {
    @ViewBuilder let todayDate: () -> TodayDate
    @ViewBuilder let main: () -> Main
    @ViewBuilder let bottomBar: () -> BottomBar
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    
                    self.todayDate()
                        .offset(y: -40)

                    ScrollView {
                        VStack(spacing: 16) {
                            self.main()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 80)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onTapGesture {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    self.bottomBar()
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
