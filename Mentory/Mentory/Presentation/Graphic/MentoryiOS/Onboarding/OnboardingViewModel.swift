//
//  OnboardingViewModel.swift
//  Mentory
//
//  Created by 구현모 on 11/14/25.
//

import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Properties
    private let onboardingModel: Onboarding

    @Published var nickname: String = ""

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(onboardingModel: Onboarding) {
        self.onboardingModel = onboardingModel

        // nickname를 도메인 모델과 동기화
        $nickname
            .sink { [weak onboardingModel] newValue in
                onboardingModel?.setName(newValue)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions
    func canProceed() -> Bool {
        return !nickname.isEmpty
    }

    func proceed() {
        guard canProceed() else { return }

        onboardingModel.validateInput()

        if onboardingModel.validationResult == .none {
            onboardingModel.next()
        }
    }
}
