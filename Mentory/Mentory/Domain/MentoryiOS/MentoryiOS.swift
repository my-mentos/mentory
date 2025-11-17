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
    init() { }
    
    private nonisolated let userNameDefaultsKey = "mentory.userName"

    // MARK: state
    nonisolated let id: UUID = UUID()
    nonisolated let logger = Logger(subsystem: "MentoryiOS", category: "Domain")
    
    @Published var userName: String? = nil
    @Published var onboardingFinished: Bool = false
    
    @Published var onboarding: Onboarding? = nil
    @Published var todayBoard: TodayBoard? = nil
    @Published var settingBoard: SettingBoard? = nil
    
    // MARK: action
    func saveUserName() {
        guard let name = userName else {
            UserDefaults.standard.removeObject(forKey: userNameDefaultsKey)
            return
        }
        UserDefaults.standard.set(name, forKey: userNameDefaultsKey)
    }
    
    func loadUserName() {
        if let savedName = UserDefaults.standard.string(forKey: userNameDefaultsKey) {
            self.userName = savedName
            self.onboardingFinished = true
            
            if self.todayBoard == nil {
                let todayBoard = TodayBoard(owner: self)
                self.todayBoard = todayBoard
                todayBoard.recordForm = RecordForm(owner: todayBoard)
            }
        } else {
            self.onboardingFinished = false
        }
    }
    
    func getGreetingText() -> String {
        let name = userName ?? "userName"
        return "반가워요, \(name)님!"
    }
    
    func setUp() {
        if userName != nil {
            return
        }
        guard onboarding == nil else {
            logger.error("Onboarding 객체가 이미 존재합니다.")
            return
        }
        self.onboarding = Onboarding(owner: self)
    }
}
