//
//  OnboardingView.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel

    init(onboardingModel: Onboarding) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(onboardingModel: onboardingModel))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 타이틀
            HStack {
                Text("감정 케어 앱, Mentory")
                    .font(.system(size: 24, weight: .bold))
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
                    title: "여러분의 감정을 기록해보세요",
                    subtitle: "매일매일 기록한 감정을 분석해드려요"
                )

                FeatureRow(
                    title: "여러분의 감정을 기록해보세요",
                    subtitle: "매일매일 기록한 감정을 분석해드려요"
                )

                FeatureRow(
                    title: "여러분의 감정을 기록해보세요",
                    subtitle: "매일매일 기록한 감정을 분석해드려요"
                )

                FeatureRow(
                    title: "여러분의 감정을 기록해보세요",
                    subtitle: "매일매일 기록한 감정을 분석해드려요"
                )
            }
            .padding(.horizontal, 30)

            Spacer()

            // 닉네임 입력 필드
            TextField("이름(닉네임)을 적어주세요.", text: $viewModel.nickname)
                .padding()
                .frame(height: 60)
                .background(Color(white: 0.95))
                .cornerRadius(16)
                .padding(.horizontal, 30)
                .padding(.bottom, 16)

            // 계속 버튼
            Button(action: {
                viewModel.proceed()
            }) {
                Text("계속")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(viewModel.canProceed() ? Color.blue : Color.gray)
                    .cornerRadius(16)
            }
            .disabled(!viewModel.canProceed())
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

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 클립보드 아이콘
            Image(systemName: "clipboard.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let mentoryiOS = MentoryiOS()
    mentoryiOS.setUp()
    return OnboardingView(onboardingModel: mentoryiOS.onboarding!)
}
