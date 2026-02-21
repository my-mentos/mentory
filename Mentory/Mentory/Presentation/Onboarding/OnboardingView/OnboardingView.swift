//
//  OnboardingView.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
//
import SwiftUI


// MARK: View
struct OnboardingView: View {
    // MARK: model
    @ObservedObject var onboarding: Onboarding
    
    init(_ onboarding: Onboarding) {
        self.onboarding = onboarding
    }
    
    
    // MARK: body
    var body: some View {
        VStack(spacing: 16) {
            // 닉네임 입력 필드
            TextField("이름(닉네임)을 적어주세요.", text: $onboarding.nameInput)
                .padding()
                .frame(height: 60)
                .background(Color.mentorySubCard)
                .cornerRadius(16)
                .submitLabel(.done)
            
            // 계속 버튼
            Button(action: {
                Task {
                    onboarding.validateInput()
                    onboarding.next()
                    if let mentoryiOS = onboarding.owner {
                        await mentoryiOS.saveUserName()
                    }
                }
            }) {
                Text("계속")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(onboarding.nameInput.isEmpty ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(onboarding.nameInput.isEmpty
                                ? Color.mentoryAccentPrimary.opacity(0.4)
                                : Color.mentoryAccentPrimary
                    )
                    .cornerRadius(16)
            }
            .disabled(onboarding.nameInput.isEmpty)
        }
        .padding()
        .background(Color.mentoryBackground.ignoresSafeArea())
    }
}


// MARK: Preview
fileprivate struct OnboardingPreview: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let onboarding = mentoryiOS.onboarding {
            OnboardingView(onboarding)
        } else if mentoryiOS.onboardingFinished {
            Text("Onboarding이 종료되었습니다.")
        } else {
            ProgressView()
                .task {
                    print(mentoryiOS.onboarding != nil)
                    mentoryiOS.setUp()
                }
        }
    }
}

#Preview {
    OnboardingPreview()
}
