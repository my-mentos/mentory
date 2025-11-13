//
//  ContentView.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var message = "로그인 전"
    @State private var isLoggedIn = false
    
    var body: some View {
        VStack {
            Text("로그인 테스트")
                .font(.title)
                .padding()
            
            TextField("이메일", text: $email)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            SecureField("비밀번호", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("로그인") {
                login()
            }
            .buttonStyle(.borderedProminent)
            
            Text(message)
                .foregroundColor(isLoggedIn ? .green : .red)
                .padding()
            
            if isLoggedIn {
                Button("로그아웃") {
                    logout()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                message = "로그인 실패: \(error.localizedDescription)"
                isLoggedIn = false
            } else {
                message = "로그인 성공. \n이메일: \(result?.user.email ?? "") \nUID: \(result?.user.uid ?? "")"
                print("사용자 UID: \(result?.user.uid ?? ""), 이메일: \(result?.user.email ?? "")")
                isLoggedIn = true
            }
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
        message = "로그아웃됨"
        isLoggedIn = false
        email = ""
        password = ""
    }
}

#Preview {
    ContentView()
}
