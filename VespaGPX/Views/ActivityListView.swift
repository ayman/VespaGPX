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

    @State private var selection = Set<Activity>()
    @State var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            List(activities,
                 id: \.self,
                 selection: $selection) { activity in
                NavigationLink {
                    ActivityView(activity: activity)
                } label: {
                    ActivityRowView(item: activity)
                }
            }
                 .navigationTitle(Text("Activities"))
                 .toolbar {
                     ToolbarItem(placement: .topBarLeading) {
                         DownloadButton(minimal: true)
                             .disabled(editMode != .inactive)
                     }
                     ToolbarItem {
                         if editMode == .active {
                             Button(action: {
                                 // TODO: pop up a modal to ask GPX or CSV
                                 // TODO: export group
                                 getSelection()
                             }) {
                                 HStack {
                                     Image(systemName: "square.and.arrow.up")
                                     Text("Export")
                                 }
                             }
                         }
                     }
                     ToolbarItemGroup(placement: .topBarTrailing) {
                         EditButton()
                     }
                 }
                 .environment(\.editMode, $editMode)
        }
        .environmentObject(viewModel)
    }

    func getSelection() {
        print(self.selection.count)
    }
}

#Preview {
    ActivityListView()
        .environmentObject(ViewModel())
}
