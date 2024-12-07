//
//  ContentView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/14/24.
//

import SwiftUI
import SwiftData

enum Tabs: Equatable, Hashable {
    case activities
    case vehicles
    case rider
    case about
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showFileImporter = false
    @StateObject private var viewModel = ViewModel()
    @Query(sort: [SortDescriptor(\Activity.id, order: .reverse)]) private var activities: [Activity]

    var body: some View {
        ZStack {
            if activities.isEmpty {
                FirstView()
            } else {
                TabView {
                    Tab("Activities", systemImage: "road.lanes") {
                        ActivityListView()
                    }
                    Tab("Vehicles", systemImage: "motorcycle.fill") {
                        VehiclesView()
                    }
                    Tab("Rider", systemImage: "person.fill") {
                        UserView()
                    }
                    Tab("About", systemImage: "info") {
                        AboutView()
                    }
                }
            }
            if viewModel.downloading {
                LoadingView()
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview("First Run") {
    ContentView()
        .modelContainer(for: Activity.self, inMemory: true)

}

#Preview("Loaded") {
    ContentView()
        .modelContainer(previewContainer)
        .environmentObject(ViewModel())
}
