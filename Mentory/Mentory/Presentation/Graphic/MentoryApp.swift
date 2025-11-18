//
//  MentoryApp.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//
import SwiftUI


// MARK: App
@main
struct MentoryApp: App {
    // MARK: model
    @State var mentoryiOS = MentoryiOS(
        mentoryDB: MentoryDB(),
        alanLLM: AlanLLM()
    )
    
    
    // MARK: body
    var body: some Scene {
        WindowGroup {
            MentoryiOSView(mentoryiOS)
        }
    }
}
