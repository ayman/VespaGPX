//
//  AboutView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/22/24.
//

import SwiftUI
import SwiftData

struct AboutView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Activity.id, order: .reverse)]) private var activities: [Activity]

    var body: some View {
        let versionNumber = "Version: \(AppSettings.shared.versionNumber)"
        NavigationStack {
            Form {
                Section(header: Text(versionNumber)) {
                    Image("VespaGPX")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 128, height: 128)
                        .cornerRadius(10)
                    Text(AppSettings.shared.appName)
                        .font(.title)
                    Text("This is a simple converter utility for the JSON outputs from the official Vespa app.  You can export/backup your data from the Vepsa app which writes a JSON file.  Have this app read that file and you can export GPX files or raw telemetry data as CSVs.")
                    Text("\(AppSettings.shared.appName) is free, open source, and not affiliated with Vespa in any way. This app is completely private...\(Text("no data is ever collected and no tracking is happening").italic()).")
                    Text("https://shamur.ai/bin/vespaGPX")
                }
                .listRowSeparator(.hidden)
                Section("Help") {
                    Text("""
                         To use this app, you'll need to be using the [Vespa iOS app](https://apps.apple.com/us/app/vespa/id1389278133) to track your rides.  You'll need to manually backup the data by going to:
                         """)
                    .listRowSeparator(.hidden)

                    Text("Settings➡Backup➡Export").monospaced()
                        .listRowSeparator(.hidden)
                    Text("""
                         Then load the exported JSON file into this app and export whatever trips you like!
                         """)
                    .listRowSeparator(.hidden)
                    Text("""
                         \(Text("Need more help?").italic()) There are [detailed instructions on the web](https://shamur.ai/bin/vespaGPX).
                         """)
                }
                Section("GPX Exporting") {
                    Text("\(Text("GPX data").bold()) is an XML file of the trip's GPS coordinates, elevation, and time stamps.")
                }
                Section("CSV Exporting") {
                    Text("\(Text("CSV data").bold()) contains telemetry as:\n\(Text("ts, distance, speed, rpm, consumption, avg_consumption, gas, acceleration, batteryVoltage, EcuWarningLamp, MilLamp, EcuUrgentServiceFlag, oilAlarm, engineTemp, wheelSlip.").monospaced())")
                    HStack {
#if targetEnvironment(simulator)
                        ShareLink(item: "",
                                  preview: SharePreview("allTrips.csv")) {
                            Label("Export all trips as CSV",
                                  systemImage: "square.and.arrow.up.on.square")
                        }
#else
                        ShareLink(item: self.makeBigCSVFile(),
                                  preview: SharePreview("allTrips.csv")) {
                            Label("Export all trips as CSV",
                                  systemImage: "square.and.arrow.up.on.square")
                        }
#endif
                    }
                }
                Section("License") {
                    Text("CryptoSwift: This product includes software developed by the \"Marcin Krzyzanowski\" (http://krzyzanowskim.com/).").font(.caption)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Text("About"))
        }
    }

    func makeBigCSVFile() -> CSVFile {
        var files = [String]()
        var names = [String]()
        activities.forEach { activity in
            names.append(activity.id)
            files.append(activity.tripData)
        }
        let csv = CSVMaker.merge(names: names, csvFiles: files)
        return CSVFile(fileName: "allTrips.csv",
                       content: csv)
    }
}

#Preview {
    AboutView()
        .environmentObject(ViewModel())
        .modelContainer(previewContainer)
}
