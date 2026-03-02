//
//  Mentory.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import Combine
import OSLog
import Values
import FirebaseLLMAdapter
import MentoryDBAdapter
import iOSReminder
import WatchManager


// MARK: Object
@MainActor
public final class Mentory: Sendable, ObservableObject {
    // MARK: core
    private nonisolated let logger = Logger()
    
    internal nonisolated let mentoryDB: any MentoryDBInterface
    internal nonisolated let firebaseLLM: any FirebaseLLMAdapterInterface
    internal nonisolated let reminderCenter: any ReminderNotificationInterface

    public init(_ mode: SystemMode = .test) {
        switch mode {
        case .real:
            self.mentoryDB = MentoryDBAdapter()
            self.firebaseLLM = FirebaseLLMAdapter()
            self.reminderCenter = ReminderNotificationAdapter()
        case .test:
            self.mentoryDB = MentoryDBFakeAdapter()
            self.firebaseLLM = FirebaseLLMFakeAdapter()
            self.reminderCenter = ReminderNotificationAdapter()
        }
    }
    
    
    // MARK: state
    public nonisolated let informationURL = URL.info
    
    @Published public var userName: String? = nil
    public func getGreetingText() -> String {
        guard let userName else {
            return "반가워요!"
        }
        
        return "반가워요, \(userName)님!"
    }
    
    @Published public var onboardingFinished: Bool = false
    
    @Published public var onboarding: Onboarding? = nil
    @Published public var todayBoard: TodayBoard? = nil
    @Published public var settingBoard: SettingBoard? = nil
    @Published public var statBoard: StatBoard? = nil
    
    public var watchConnectivity: (any WatchConnectivityInterface)? = nil
    
    
    // MARK: action
    public func setUp() {
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
    
    public func loadUserName() async {
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
    public func saveUserName() async {
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
    
    
    // MARK: value
    public struct URL: Sendable, Hashable {
        // MARK: core
        public let rawValue: Foundation.URL
        
        public static let info: Self = .init(rawValue: Foundation.URL(string: "https://nice-asp-f94.notion.site/Mentory-Information-2b11c49e815f80c5873befe3b6847f70?source=copy_link")!)
        
        private init(rawValue: Foundation.URL) {
            self.rawValue = rawValue
        }
    }
}
