//
//  MentoryWatchApp.swift
//  MentoryWatch Watch App
//
//  Created by 구현모 on 11/19/25.
//

import SwiftUI

@main
struct MentoryWatch_Watch_AppApp: App {
    // MARK: WatchConnectivity
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared

    init() {
        Task {
            await WatchConnectivityManager.shared.setUp()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchConnectivity)
        }
    }
}
