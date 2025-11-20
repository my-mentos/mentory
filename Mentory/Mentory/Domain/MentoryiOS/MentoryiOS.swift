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
    nonisolated let mentoryDB: any MentoryDBInterface
    nonisolated let alanLLM: any AlanLLMInterface
    var recordRepository: MentoryRecordRepositoryInterface?

    init(
        mentoryDB: any MentoryDBInterface = MentoryDBMock(),
        alanLLM: any AlanLLMInterface = AlanLLMMock(),
        recordRepository: MentoryRecordRepositoryInterface? = nil
    ) {
        self.mentoryDB = mentoryDB
        self.alanLLM = alanLLM
        self.recordRepository = recordRepository
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

        let todayBoard = TodayBoard(owner: self, recordRepository: self.recordRepository)
        self.todayBoard = todayBoard
        todayBoard.recordForm = RecordForm(owner: todayBoard)

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
            try await self.mentoryDB.updateName(userName)
        } catch {
            logger.error("\(error)")
            return
        }
    }
}
