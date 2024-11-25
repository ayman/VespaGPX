//
//  UserView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/16/24.
//

import SwiftUI
import SwiftData

struct UserView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfile: [UserProfile]
    @Query private var userSettings: [UserSettings]
    @Query private var versionInfo: [VersionInfo]

    var body: some View {
        NavigationStack {
            Form {
                Section("User Profile") {
                    if !userProfile.isEmpty {
                        let profile = userProfile[0]
                        SimpleRowView(left: "id",
                                      right: profile.id,
                                      noSpacing: true)

                        HStack {
                            Text("avatar")
                                .font(.footnote)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Image(uiImage: profile.avatar)
                                .resizable()
                                .ignoresSafeArea()
                                .aspectRatio(contentMode: .fill)
                                .frame(alignment: .trailing)
                        }
                    }
                }

                Section("User Settings") {
                    if !userSettings.isEmpty {
                        let settings = userSettings[0]
                        SimpleRowView(left: "isAutostartNaviEnabled",
                                      right: "\(settings.isAutostartNaviEnabled.description)")
                        SimpleRowView(left: "isSafeDrivingEnabled",
                                      right: "\(settings.isSafeDrivingEnabled)")
                        SimpleRowView(left: "shouldDisplayInCelsius",
                                      right: "\(settings.shouldDisplayInCelsius)")
                        SimpleRowView(left: "shouldEnableAutoFollowMe",
                                      right: "\(settings.shouldEnableAutoFollowMe)")
                        SimpleRowView(left: "shouldSynchronizeClock",
                                      right: "\(settings.shouldSynchronizeClock)")
                        SimpleRowView(left: "shouldDisplayInKm",
                                      right: "\(settings.shouldDisplayInKm)")
                        SimpleRowView(left: "shouldSynchronizeData",
                                      right: "\(settings.shouldSynchronizeData)")
                        SimpleRowView(left: "settings.shouldRecordTripData)",
                                      right: "\(settings.shouldRecordTripData)")
                    }
                }

                Section("Version Info") {
                    if !versionInfo.isEmpty {
                        let info = versionInfo[0]
                        SimpleRowView(left: "appVersion", right: info.appVersion)
                        SimpleRowView(left: "platform", right: info.platform)
                        SimpleRowView(left: "appName", right: info.appName)
                        SimpleRowView(left: "platformVersion", right: info.platformVersion)
                        SimpleRowView(left: "uUID", right: info.uUID, noSpacing: true)

                    }
                }
            }
        }
        .navigationTitle(Text("Rider"))
    }
}

#Preview {
    UserView()
}