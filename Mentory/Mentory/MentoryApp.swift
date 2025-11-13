//
//  MentoryApp.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//

import SwiftUI
import FirebaseCore

@main
struct MentoryApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
