//
//  ActivityListView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/17/24.
//

import SwiftUI
import SwiftData

// https://medium.com/swiftable/swiftui-how-to-enable-single-multiple-selection-in-list-dc93cf9d4174

struct ActivityListView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Activity.id, order: .reverse)]) private var activities: [Activity]

    var body: some View {
        NavigationStack {
            List {
                ForEach(activities) { activity in
                    NavigationLink {
                        ActivityView(activity: activity)
                    } label: {
                        ActivityRowView(item: activity)
                    }
                }
            }
            .navigationTitle(Text("Activities"))
            .toolbar {
                DownloadButton(minimal: true)
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    ActivityListView()
}
