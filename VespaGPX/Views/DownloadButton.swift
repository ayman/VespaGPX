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
    var minimal: Bool = false

    var body: some View {
        if minimal {
            Button(action: { showFileImporter = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Load JSON")
                }
            }
            .disabled(self.viewModel.downloading)
            .buttonStyle(.borderless)
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [.json],
                          allowsMultipleSelection: false,
                          onCompletion: getFileData)
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
        }
    }

    private func getFileData(result: Result<[URL], any Error>) {
        self.viewModel.downloading = true
        viewModel.loadTimer = 0.0
        Task {
            switch result {
            case .success(let files):
                print("!!\(files[0])")
                do {
                    viewModel.loadTimer = 0.0
                    guard let selectedFile: URL = try result.get().first else { return }
                    let gotAccess = selectedFile.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    viewModel.loadTimer = 1.0
                    guard let fileString = String(data: try Data(contentsOf: selectedFile),
                                                  encoding: .utf8) else { return }
                    selectedFile.stopAccessingSecurityScopedResource()
                    viewModel.loadTimer = 2.0
                    await viewModel.decodeJSON(string: fileString)
                    self.storeActivities()
                    if let payload = viewModel.payload {
                        self.storeUserProfile(profile: payload.userProfile)
                        self.storeUserSettings(settings: payload.userSettings)
                        self.storeVehicles(vehicles: payload.vehicles)
                        self.storeVersionInfo(versionInfo: payload.versionInfo)
                        self.viewModel.downloading = false
                        viewModel.loadTimer = 0.0
                    }
                } catch {
                    print("Loading Failure")
                }
            case .failure(let error):
                print(error)
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
