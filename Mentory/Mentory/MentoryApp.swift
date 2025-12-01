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
    
    // MARK: model
    @State var mentoryiOS = MentoryiOS(.real)

    // MARK: WatchConnectivity
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared

    init() {
        _ = WatchConnectivityManager.shared
    }

    // MARK: body
    var body: some Scene {
        WindowGroup {
            MentoryiOSView(mentoryiOS)
                .environmentObject(watchConnectivity)
        }
    }
}
