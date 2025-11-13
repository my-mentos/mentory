//
//  SignInForm.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import Combine


// MARK: Object
@MainActor
final class SignInForm: Sendable, ObservableObject {
    // MARK: core
    init(owner: SampleCounter) {
        self.owner = owner
    }
    
    
    // MARK: state
    let owner: SampleCounter
    
    @Published var signUpForm: SignUpForm? = nil
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    
    // MARK: action
    func submit() {
        // 서버로 데이터를 보내서 검증
        // 만약 성공한다면?
        
        // mutate
        owner.signInForm = nil
        owner.newCounter = NewCounter(owner: owner)
        owner.isSigned = true
    }
    
    func setUpSignUpForm() {
        // mutate
        self.signUpForm = SignUpForm(owner: self)
    }
}
