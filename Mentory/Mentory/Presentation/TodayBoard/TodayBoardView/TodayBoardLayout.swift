//
//  TodayBoardLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/23/25.
//
import Foundation
import SwiftUI


// MARK: View
struct TodayBoardLayout<Content:View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        
    }
}
