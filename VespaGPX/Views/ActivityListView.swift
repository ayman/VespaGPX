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
    @State var showAlert = false

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
                 .toolbar {
                     if editMode == .inactive {
                             ToolbarItem(placement: .topBarLeading) {
                                 DownloadButton(minimal: true)
                                     .disabled(editMode != .inactive)
                             }
                     }
                     if editMode == .active {
                         ToolbarItem {
#if targetEnvironment(simulator)
                             ShareLink(item: "",
                                       preview: SharePreview("trips.csv")) {
                                 Label("Export CSV",
                                       systemImage: "square.and.arrow.up.on.square")
                                 .labelStyle(.titleOnly)
                             }
                                       .disabled(self.selection.isEmpty)

#else
                             ShareLink(item: getCSVs(),
                                       preview: SharePreview("trips.csv")) {
                                 Label("Export CSV",
                                       systemImage: "square.and.arrow.up.on.square")
                                 .labelStyle(.titleOnly)
                             }
                                       .disabled(self.selection.isEmpty)
#endif
                         }
                         ToolbarItem {
#if targetEnvironment(simulator)
                             ShareLink(item: "",
                                       preview: SharePreview("trips.gpx")) {
                                 Label("Export GPX",
                                       systemImage: "square.and.arrow.up.on.square")
                                 .labelStyle(.titleOnly)
                             }
                                       .disabled(self.selection.isEmpty)

#else
                             ShareLink(item: getGPX(),
                                       preview: SharePreview("trips.gpx")) {
                                 Label("Export GPX",
                                       systemImage: "square.and.arrow.up.on.square")
                                 .labelStyle(.titleOnly)
                             }
                                       .disabled(self.selection.isEmpty)

#endif
                         }
                     }
                     ToolbarItemGroup(placement: .topBarTrailing) {
                         EditButton()
                     }
                 }
                 .environment(\.editMode, $editMode)
                 .navigationTitle(Text("Activities"))
        }
        .environmentObject(viewModel)
    }

    func getCSVs() -> CSVFile {
        var names = [String]()
        var files = [String]()
        selection.forEach { activity in
            names.append(activity.id)
            files.append(activity.tripData)
        }
        let csvs = CSVMaker.merge(names: names,
                                     csvFiles: files)
        return CSVFile(fileName: "trips.csv", content: csvs)
    }

    func getGPX() -> GPXFile {
        var gpxData = [String]()
        selection.forEach { activity in
            gpxData.append(activity.gpsData)
        }
        var gpsRows = [[GPSRow]]()
        gpxData.forEach { data in
            gpsRows.append(GPXMaker.parseGpsCSV(gpsData: data))
        }
        gpsRows.sort(by: { Double($0.first!.ts) ?? 0.0 <= Double($1.first!.ts) ?? 1.0 })
        let gpx = GPXMaker.mergeGPX(gpsRows: gpsRows)
        return GPXFile(fileName: "trips.gpx", content: gpx)
    }

    func clearSelection() {
        selection.removeAll()
        editMode = .inactive
    }
}

#Preview {
    ActivityListView()
        .modelContainer(previewContainer)
        .environmentObject(ViewModel())
}
