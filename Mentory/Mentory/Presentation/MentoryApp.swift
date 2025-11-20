//
//  MentoryApp.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//
import SwiftUI
import SwiftData


// MARK: App
@main
struct MentoryApp: App {
    // MARK: SwiftData
    let modelContainer: ModelContainer

    // MARK: model
    @State var mentoryiOS: MentoryiOS

    init() {
        // ModelContainer 초기화
        do {
            modelContainer = try ModelContainer(for: MentoryRecord.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }

        // Repository 생성
        let repository = MentoryRecordRepository(modelContext: modelContainer.mainContext)

        // MentoryiOS 초기화
        mentoryiOS = MentoryiOS(
            mentoryDB: MentoryDB(),
            alanLLM: AlanLLM(),
            recordRepository: repository
        )
    }


    // MARK: body
    var body: some Scene {
        WindowGroup {
            MentoryiOSView(mentoryiOS)
        }
        .modelContainer(modelContainer)
    }
}
