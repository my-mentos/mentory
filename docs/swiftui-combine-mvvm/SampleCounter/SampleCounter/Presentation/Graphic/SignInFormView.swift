//
//  SignInFormView.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import SwiftUI


// MARK: View
struct SignInFormView: View {
    @ObservedObject var signInForm: SignInForm
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case email
        case password
    }
    
    init(_ signInForm: SignInForm) {
        self.signInForm = signInForm
    }
    
    var body: some View {
        Form {
            Section(header: Text("계정 정보"), footer: footerText) {
                TextField("아이디를 입력하세요", text: $signInForm.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }
                SecureField("비밀번호를 입력하세요", text: $signInForm.password)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .password)
            }
            
            Section {
                Button {
                    focusedField = nil
                    signInForm.submit()
                } label: {
                    Label("로그인", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("이메일 로그인")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") { focusedField = nil }
            }
        }
    }
    
    private var footerText: some View {
        Text("이메일과 비밀번호는 대/소문자를 구분합니다.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}


#Preview {
    let app = SampleCounter()
    
    SignInFormView(SignInForm(owner: app))
}
