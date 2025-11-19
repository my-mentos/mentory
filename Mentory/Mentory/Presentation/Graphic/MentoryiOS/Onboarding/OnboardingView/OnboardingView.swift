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
        VStack(spacing: 0) {
            // 타이틀
            HStack {
                Text("감정 케어 앱, Mentory")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 60)
                    .padding(.leading, 30)
                Spacer()
            }
            
            // 캐릭터 표시 영역
            HStack(spacing: 40) {
                // 구름이 캐릭터
                VStack(spacing: 12) {
                    Image("gureum")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("온화한 성격의 구름이")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                
                // 분석이 캐릭터
                VStack(spacing: 12) {
                    Image("bunsuk")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("냉철한 성격의 분석이")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 40)
            
            // 기능 설명 리스트
            VStack(alignment: .leading, spacing: 20) {
                OnboardingDetailView(
                    title: "텍스트, 음성, 이미지로 감정 기록",
                    subtitle: "당신이 편한 방식으로 일상을 기록해보세요",
                    image: "pencil.and.list.clipboard"
                )
                
                OnboardingDetailView(
                    title: "AI가 분석하는 나의 감정 상태",
                    subtitle: "7단계 감정 분류로 내 마음 상태를 정확히 파악해요",
                    image: "brain.head.profile"
                )
                
                OnboardingDetailView(
                    title: "구름이, 분석이와 함께하는 감정 케어",
                    subtitle: "당신의 성향에 맞는 캐릭터가 위로와 조언을 전해요",
                    image: "message.fill"
                )
                
                OnboardingDetailView(
                    title: "감정 캘린더와 맞춤형 행동 추천",
                    subtitle: "통계로 감정을 추적하고 실천 가능한 활동을 받아보세요",
                    image: "calendar"
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // 닉네임 입력 필드
            TextField("이름(닉네임)을 적어주세요.", text: $onboarding.nameInput)
                .padding()
                .frame(height: 60)
                .background(Color(white: 0.95))
                .cornerRadius(16)
                .padding(.horizontal, 30)
                .padding(.bottom, 16)
            
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
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(onboarding.nameInput.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(16)
            }
            .disabled(onboarding.nameInput.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(Color.white)
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
