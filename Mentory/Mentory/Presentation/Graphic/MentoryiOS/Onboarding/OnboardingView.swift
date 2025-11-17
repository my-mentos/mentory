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
    @ObservedObject var onboardingModel: Onboarding

    
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
                FeatureRow(
                    title: "텍스트, 음성, 이미지로 감정 기록",
                    subtitle: "당신이 편한 방식으로 일상을 기록해보세요",
                    image: "pencil.and.list.clipboard"
                )

                FeatureRow(
                    title: "AI가 분석하는 나의 감정 상태",
                    subtitle: "7단계 감정 분류로 내 마음 상태를 정확히 파악해요",
                    image: "brain.head.profile"
                )

                FeatureRow(
                    title: "구름이, 분석이와 함께하는 감정 케어",
                    subtitle: "당신의 성향에 맞는 캐릭터가 위로와 조언을 전해요",
                    image: "message.fill"
                )

                FeatureRow(
                    title: "감정 캘린더와 맞춤형 행동 추천",
                    subtitle: "통계로 감정을 추적하고 실천 가능한 활동을 받아보세요",
                    image: "calendar"
                )
            }
            .padding(.horizontal, 30)

            Spacer()

            // 닉네임 입력 필드
            TextField("이름(닉네임)을 적어주세요.", text: $onboardingModel.nameInput)
                .padding()
                .frame(height: 60)
                .background(Color(white: 0.95))
                .cornerRadius(16)
                .padding(.horizontal, 30)
                .padding(.bottom, 16)

            // 계속 버튼
            Button(action: {
                Task {
                    onboardingModel.validateInput()
                    onboardingModel.next()
                }
            }) {
                Text("계속")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(onboardingModel.nameInput.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(16)
            }
            .disabled(onboardingModel.nameInput.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

// MARK: - Feature Row View
struct FeatureRow: View {
    let title: String
    let subtitle: String
    let image: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 클립보드 아이콘
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.black)


            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Preview
#Preview {
    let mentoryiOS = MentoryiOS()
    mentoryiOS.setUp()
    return OnboardingView(onboardingModel: mentoryiOS.onboarding!)
}
