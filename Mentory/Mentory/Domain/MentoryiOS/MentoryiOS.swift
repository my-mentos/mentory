//
//  MentoryiOS.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class MentoryiOS: Sendable, ObservableObject {
    // MARK: core
    init() {
        
    }

    // MARK: state
    nonisolated let id: UUID = UUID()
    nonisolated let logger = Logger(subsystem: "MentoryiOS.MentoryiOS",
                                    category: "Domain")
    
    @Published var userName: String? = nil
    func getGreetingText() -> String {
        guard let userName else {
            return "반가워요!"
        }
        
        return "반가워요, \(userName)님!"
    }
    
    @Published var onboardingFinished: Bool = false
    @Published var onboarding: Onboarding? = nil
    
    @Published var todayBoard: TodayBoard? = nil
    @Published var settingBoard: SettingBoard? = nil
    
    
    // MARK: action
    func setUp() {
        // capture
        guard onboardingFinished == false else {
            logger.error("Onboarding이 이미 완료되어 있어 종료됩니다.")
            return
        }
        guard userName == nil else {
            logger.error("MentoryiOS의 userName이 현재 nil이서 종료됩니다.")
            return
        }
        guard onboarding == nil else {
            logger.error("Onboarding 객체가 이미 존재합니다.")
            return
        }
        
        // mutate
        self.onboarding = Onboarding(owner: self)
    }
    
    private nonisolated let userNameDefaultsKey = "mentory.userName"
    func saveUserName() {
        guard let name = userName else {
            UserDefaults.standard.removeObject(forKey: userNameDefaultsKey)
            return
        }
        UserDefaults.standard.set(name, forKey: userNameDefaultsKey)
    }
    
    func loadUserName() {
        // process
        if let savedName = UserDefaults.standard.string(forKey: userNameDefaultsKey) {
            self.userName = savedName
            self.onboardingFinished = true
            
            if self.todayBoard == nil {
                let todayBoard = TodayBoard(owner: self)
                self.todayBoard = todayBoard
                todayBoard.recordForm = RecordForm(owner: todayBoard)
            }
        } else {
            // mutate
            self.onboardingFinished = false
        }
    }
}
