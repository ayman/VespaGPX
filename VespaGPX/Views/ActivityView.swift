//
//  ActivityView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/16/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ActivityView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showingCSVAlert = false
    @State private var showingGPXAlert = false
    let activity: Activity

    var body: some View {
        let distance = String(format: "%.1f", activity.distance)
        let duration = String(format: "%.0f", activity.duration * 0.01)
        let gpx = getGPX()
        let gpxFile = GPXFile(fileName: "\(activity.id).gpx",
                              content: gpx)
        let csvFile = CSVFile(fileName: "\(activity.id).csv",
                              content: activity.tripData.replacingOccurrences(of: ";",
                                                                              with: ","))

        Form {
            Section("Export") {
                HStack {
                    ShareLink(item: gpxFile,
                              preview: SharePreview(gpxFile.fileName)) {
                        Label("Export GPX",
                              systemImage: "square.and.arrow.up")
                    }
                }
                HStack {
                    ShareLink(item: csvFile,
                              preview: SharePreview(csvFile.fileName)) {
                        Label("Export CSV",
                              systemImage: "square.and.arrow.up")
                    }
                }
            }
            Section("Activity Summary") {
                SimpleRowView(left: "avgTripFuelConsumption", right: String(format: "%.1f", activity.avgTripFuelConsumption))
                SimpleRowView(left: "id", right: activity.id)
                SimpleRowView(left: "tractionControlCounter", right: String(activity.tractionControlCounter))
                SimpleRowView(left: "endTimestamp", right: String(format: "%.6f", activity.endTimestamp))
                SimpleRowView(left: "tripLitersConsumed", right: String(format: "%.1f", activity.tripLitersConsumed))
                SimpleRowView(left: "userId", right: activity.userId, noSpacing: true)
                SimpleRowView(left: "distance", right: distance)
                SimpleRowView(left: "type", right: activity.type)
                SimpleRowView(left: "vehicleId", right: activity.vehicleId, noSpacing: true)
                SimpleRowView(left: "startTimestamp", right: String(format: "%.6f", activity.startTimestamp))
                SimpleRowView(left: "duration", right: duration)
            }

        }
        .navigationTitle(activity.id)
        .navigationBarTitleDisplayMode(.automatic)
    }

    func getGPX() -> String {
        let rows = GPXMaker.parseGpsCSV(gpsData: activity.gpsData)
        return GPXMaker.getGPX(gpsRows: rows)
    }
}

#Preview {
    ActivityView(activity: Activity.dummy)
        .environmentObject(ViewModel())
}
