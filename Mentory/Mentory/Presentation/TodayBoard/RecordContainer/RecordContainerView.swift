//
//  RecordContainerView.swift
//  Mentory
//
//  Created by JAY on 12/2/25.
//

import Foundation
import SwiftUI
import Combine


//// MARK: View
//struct RecordContainerView: View {
//    @State private var navigationPath = NavigationPath()
//    @State private var isSubmitEnabled = false
//    @ObservedObject var recordForm: RecordForm
//    
//    
//    // MARK: - Body
//    var body: some View {
//        NavigationStack(path: $navigationPath) {
//            RecordFormView(recordForm: recordForm)
//                .toolbar {
//                    // MARK: 취소 버튼
//                    ToolbarItem(placement: .navigationBarLeading) {
//                            Button {
//                                if navigationPath.isEmpty {
//                                    recordForm.finish() // RecordFormView에서 보일 뒤로가기 버튼
//                                } else {
//                                    navigationPath.removeLast() // MindAnalyzerView에서 RecordFormView으로 가는 버튼
//                                }
//                            } label: {
//                                Image(systemName: "xmark")
//                            }
//                    }
//                }
//        }
//    }
//}
