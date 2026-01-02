//
//  MentoryApp.swift
//  Mentory
//
//  Created by 김민우 on 11/11/25.
//
import SwiftUI
import SwiftData
import Values


// MARK: App
@main
struct MentoryApp: App {
    // MARK: model
    @State var mentoryiOS = MentoryiOS(.test)
    @State private var watchConnectivity = WatchConnectivityManager.shared
    

    // MARK: body
    var body: some Scene {
        WindowGroup {
            MentoryiOSView(mentoryiOS)
                .environment(watchConnectivity)
        }
    }
}
