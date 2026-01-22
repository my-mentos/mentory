//
//  MindAnalyzerLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/24/25.
//
import Foundation
import SwiftUI


// MARK: Layout
struct MindAnalyzerLayout<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                self.content()
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 6)
            )
            .padding(.horizontal)
            .padding(.top, 32)
            .padding(.bottom, 40)
        }
    }
}
