////
////  OnboardingLayout.swift
////  Mentory
////
////  Created by 김민우 on 12/1/25.
////
//import SwiftUI
//
//
//// MARK: Layout
//struct OnboardingLayout<Content: View, BottomContent: View> : View {
//    let title: String
//    @ViewBuilder let main: () -> Content
//    @ViewBuilder let bottom: () -> BottomContent
//    
//    var body: some View {
//        ZStack {
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//                    HStack {
//                        Text(title)
//                            .font(.system(size: 32, weight: .bold))
//                            .foregroundColor(.primary)
//                            .padding(.top, 60)
//                            .padding(.leading, 30)
//                        
//                        Spacer()
//                    }
//                    
//                    main()
//                    
//                    Spacer()
//                }
//            }
//        }.safeAreaInset(edge: .bottom) {
//            bottom()
//                .padding(.horizontal, 30)
//                .padding(.bottom, 40)
//            
//                .background(Color.mentoryBackground.ignoresSafeArea())
//
//        }
//        
//    }
//}
//
//
//// MARK: Preview
//#Preview {
//    OnboardingLayout(
//        title: "레이아웃 제목",
//        main: {
//            Text("컨텐츠 영역")
//        },
//        bottom: {
//            Text("하단 영역 컨텐츠")
//        })
//}
