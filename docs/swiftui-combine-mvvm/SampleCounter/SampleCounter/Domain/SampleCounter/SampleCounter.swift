//
//  SampleCounter.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import Combine
import Observation
import Foundation


// MARK: Object
@MainActor
final class SampleCounter: ObservableObject {
    // MARK: core
    
    
    // MARK: state
    @Published var signInForm: SignInForm? = nil
    @Published var newCounter: NewCounter? = nil
    
    @Published var isSigned: Bool = false
    
    @Published var number: Int = 0
    func increment() {
        number += 1
    }
    func decrement() {
        number -= 1
    }
    
    
    // MARK: action
    func setUpForm() async {
        // capture
        guard signInForm == nil else {
            print("이미 SignInForm이 존재합니다.")
            return
        }
        
        // process
        // GoogleAPI 요청
        let urlsession = URLSession.shared
        
        let result = try? await urlsession.data(for: URLRequest(url: URL(string: "https://www.google.com")!))
        
        
        // mutate
        self.signInForm = SignInForm(owner: self)
    }
}
