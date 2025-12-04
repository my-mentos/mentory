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
    nonisolated let logger = Logger(subsystem: "MentoryiOS.MentoryiOS", category: "Domain")
    nonisolated let mentoryDB: any MentoryDBInterface
    nonisolated let alanLLM: any AlanLLMInterface
    nonisolated let firebaseLLM: any FirebaseLLMInterface

    let reminderCenter: any ReminderNotificationInterface

    init(_ mode: SystemMode = .test) {
        switch mode {
        case .real:
            self.mentoryDB = MentoryDBAdapter()
            self.alanLLM = AlanLLM()
            self.firebaseLLM = FirebaseLLM()
            self.reminderCenter = ReminderNotificationAdapter()
        case .test:
            self.mentoryDB = MentoryDatabaseMock()
            self.alanLLM = AlanLLMMock()
            self.firebaseLLM = FirebaseLLMMock()
            self.reminderCenter = ReminderNotificationAdapter() // 임시
        }
    }
    
    
    // MARK: state
    public nonisolated let informationURL = URL(string: "https://nice-asp-f94.notion.site/Mentory-Information-2b11c49e815f80c5873befe3b6847f70?source=copy_link")!
    
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
    
    func loadUserName() async {
        // capture
        let mentoryDB = self.mentoryDB
        
        // process
        let userNameFromDB: String
        
        do {
            guard let name = try await mentoryDB.getName() else {
                logger.error("현재 MentoryDB에 저장된 이름이 존재하지 않습니다.")
                return
            }
            
            userNameFromDB = name
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        self.userName = userNameFromDB
        self.onboardingFinished = true

        self.todayBoard = TodayBoard(owner: self)
        self.settingBoard = SettingBoard(owner: self)
    }
    func saveUserName() async {
        // capture
        guard let userName else {
            logger.error("MentoryiOS에 userName이 존재하지 않습니다.")
            return
        }
        
        // process
        do {
            try await self.mentoryDB.setName(userName)
        } catch {
            logger.error("\(error)")
            return
        }
    }
    
    
    // MARK: view
    enum SystemMode: Sendable, Hashable {
        case test
        case real
    }
}
