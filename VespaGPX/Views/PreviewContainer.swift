//
//  PreviewContainer.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/27/24.
//

import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let schema = Schema([Activity.self,
                         UserProfile.self,
                         UserSettings.self,
                         Vehicle.self,
                         VersionInfo.self])
    let container = try! ModelContainer(for: schema,
                                        configurations: config)
    for _ in 1...5 {
        container.mainContext.insert(Activity.dummy)
    }

    container.mainContext.insert(UserProfile.dummy)
    container.mainContext.insert(UserSettings.dummy)
    container.mainContext.insert(VersionInfo.dummy)
    container.mainContext.insert(Vehicle.dummy)

    return container
}()
