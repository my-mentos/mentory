//
//  RecordFormView.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//

import SwiftUI

struct RecordFormView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @ObservedObject var recordFormModel : RecordForm
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 상단 바
            HStack {
                Image(systemName: "bookmark")
                    .font(.title3)
                    .padding(.leading)
                
                Spacer()
                
                Text("11월 17일 월요일")
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                    Button {
                        recordFormModel.submit()
                    } label: {
                        Text("완료")
                            .foregroundColor(.purple)
                    }
                }
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // 제목 입력
            TextField("제목", text: $title)
                .font(.title3)
                .padding(.horizontal)
                .padding(.top, 12)
            
            // 본문 입력
            TextEditor(text: $content)
                .padding(.horizontal)
                .padding(.top, 8)
                .overlay(
                    Group {
                        if content.isEmpty {
                            Text("글쓰기 시작…")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
            
            Spacer()
            
            Divider()
            
            // 하단 툴바
            HStack {
                Spacer()
                Image(systemName: "photo")
                Spacer()
                Image(systemName: "camera")
                Spacer()
                Image(systemName: "waveform")
                Spacer()
            }
            .padding(.vertical, 10)
            .foregroundColor(.gray)
            .background(Color(UIColor.systemGray6))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    let mentoryiOS = MentoryiOS()
    RecordFormView(recordFormModel: mentoryiOS.recordForm!)
}
