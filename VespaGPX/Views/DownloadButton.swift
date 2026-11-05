//
//  DownloadButton.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/22/24.
//

import SwiftUI

struct DownloadButton: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showFileImporter = false
    @State private var showImportError = false
    @State private var importErrorMessage = ""
    var minimal: Bool = false

    var body: some View {
        if minimal {
            Button(action: { showFileImporter = true }) {
                HStack {
                    Image(systemName: "plus")
                }
            }
            .disabled(self.viewModel.downloading)
            .buttonStyle(.borderless)
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [.json],
                          allowsMultipleSelection: false,
                          onCompletion: getFileData)
            .alert("Import failed", isPresented: $showImportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importErrorMessage)
            }
        } else {
            Button(action: { showFileImporter = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Load JSON")
                }
            }
            .disabled(self.viewModel.downloading)
            .buttonStyle(.borderedProminent)
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [.json],
                          allowsMultipleSelection: false,
                          onCompletion: getFileData)
            .alert("Import failed", isPresented: $showImportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importErrorMessage)
            }
        }
    }

    private func getFileData(result: Result<[URL], any Error>) {
        Task { @MainActor in
            viewModel.downloading = true
            viewModel.loadTimer = 0
            defer {
                viewModel.downloading = false
                viewModel.loadTimer = 0
            }
            do {
                let files = try result.get()
                guard let selectedFile = files.first else {
                    throw VespaBackupImporter.ImportError.invalidFormat
                }
                let gotAccess = selectedFile.startAccessingSecurityScopedResource()
                guard gotAccess else {
                    throw CocoaError(.fileReadNoPermission)
                }
                let fileString: String
                do {
                    fileString = try String(contentsOf: selectedFile, encoding: .utf8)
                } catch {
                    selectedFile.stopAccessingSecurityScopedResource()
                    throw error
                }
                selectedFile.stopAccessingSecurityScopedResource()
                viewModel.loadTimer = 2

                try await viewModel.decodeJSON(string: fileString)
                guard let payload = viewModel.payload else {
                    throw VespaBackupImporter.ImportError.invalidFormat
                }
                self.storeActivities()
                self.storeUserProfile(profile: payload.userProfile)
                self.storeUserSettings(settings: payload.userSettings)
                self.storeVehicles(vehicles: payload.vehicles)
                self.storeVersionInfo(versionInfo: payload.versionInfo)
                try modelContext.save()
            } catch {
                importErrorMessage = error.localizedDescription
                showImportError = true
            }
        }
    }

    func storeVehicles(vehicles: [VespaVehicle]) {
        do {
            try modelContext.delete(model: Vehicle.self)
        } catch {
            print("Failed to delete all UserSettings Items.")
        }
        if let vespas = viewModel.payload?.vehicles {
            vespas.forEach { vehicle in
                let vespa = Vehicle(name: vehicle.name,
                                    isCelsius: vehicle.isCelsius,
                                    isKm: vehicle.isKm,
                                    latestUpdate: vehicle.latestUpdate,
                                    id: vehicle.id,
                                    totalMileage: vehicle.totalMileage,
                                    engineSize: vehicle.engineSize,
                                    model: vehicle.model,
                                    vin: vehicle.vin,
                                    modelId: vehicle.modelId,
                                    modelYear: vehicle.modelYear,
                                    batteryVoltage: vehicle.batteryVoltage,
                                    userId: vehicle.userId,
                                    serial: vehicle.serial,
                                    isAssociated: vehicle.isAssociated)
                modelContext.insert(vespa)
            }
        }
    }

    func storeUserProfile(profile: VespaUserProfile) {
        do {
            try modelContext.delete(model: UserProfile.self)
        } catch {
            print("Failed to delete all UserSettings Items.")
        }

        let userProfile = UserProfile(id: profile.id, avatarData: profile.avatarData)
        modelContext.insert(userProfile)
    }

    private func storeUserSettings(settings: VespaUserSettings) {
        do {
            try modelContext.delete(model: UserSettings.self)
        } catch {
            print("Failed to delete all UserSettings Items.")
        }
        let userSettings = UserSettings(shouldSynchronizeClock: settings.shouldSynchronizeData,
                                        shouldDisplayInCelsius: settings.shouldDisplayInCelsius,
                                        isAutostartNaviEnabled: settings.isAutostartNaviEnabled,
                                        shouldDisplayInKm: settings.shouldDisplayInKm,
                                        shouldSynchronizeData: settings.shouldSynchronizeData,
                                        isSafeDrivingEnabled: settings.isSafeDrivingEnabled,
                                        shouldEnableAutoFollowMe: settings.shouldEnableAutoFollowMe,
                                        shouldRecordTripData: settings.shouldRecordTripData)
        modelContext.insert(userSettings)
    }

    func storeVersionInfo(versionInfo: VespaVersionInfo) {
        do {
            try modelContext.delete(model: VersionInfo.self)
        } catch {
            print("Failed to delete all UserSettings Items.")
        }
        let info = VersionInfo(appVersion: versionInfo.appVersion,
                               platform: versionInfo.platform,
                               appName: versionInfo.appName,
                               platformVersion: versionInfo.platformVersion,
                               uUID: versionInfo.uUID)
        modelContext.insert(info)
    }

    private func storeActivities() {
        do {
            try modelContext.delete(model: Activity.self)
        } catch {
            print("Failed to delete all Activity Items.")
        }
        if let activities = viewModel.payload?.activities {
            activities.forEach { activity in
                let tripData = viewModel.tripRaw[activity.id]
                let gpsData = viewModel.gpsRaw[activity.id]
                let newItem = Activity(avgTripFuelConsumption: activity.avgTripFuelConsumption,
                                       id: activity.id,
                                       tractionControlCounter: activity.tractionControlCounter,
                                       endTimestamp: activity.endTimestamp,
                                       tripLitersConsumed: activity.tripLitersConsumed,
                                       userId: activity.userId,
                                       distance: activity.distance,
                                       type: activity.type,
                                       vehicleId: activity.vehicleId,
                                       startTimestamp: activity.startTimestamp,
                                       duration: activity.duration,
                                       tripData: tripData ?? "",
                                       gpsData: gpsData ?? "")
                withAnimation {
                    modelContext.insert(newItem)
                }
            }
        }
    }

}

#Preview {
    DownloadButton()
        .environmentObject(ViewModel())
}
#Preview {
    DownloadButton(minimal: true)
        .environmentObject(ViewModel())
}
