//
//  VespaGPXApp.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/14/24.
//

import SwiftUI
import SwiftData

@main
struct VespaGPXApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Activity.self,
            UserProfile.self,
            UserSettings.self,
            Vehicle.self,
            VersionInfo.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
