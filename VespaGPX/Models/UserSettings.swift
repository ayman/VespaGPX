//
//  UserSettings.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/17/24.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var shouldSynchronizeClock: Bool = false
    var shouldDisplayInCelsius: Bool = false
    var isAutostartNaviEnabled: Bool = false
    var shouldDisplayInKm: Bool = false
    var shouldSynchronizeData: Bool = false
    var isSafeDrivingEnabled: Bool = false
    var shouldEnableAutoFollowMe: Bool = false
    var shouldRecordTripData: Bool = false

    init(shouldSynchronizeClock: Bool,
         shouldDisplayInCelsius: Bool,
         isAutostartNaviEnabled: Bool,
         shouldDisplayInKm: Bool,
         shouldSynchronizeData: Bool,
         isSafeDrivingEnabled: Bool,
         shouldEnableAutoFollowMe: Bool,
         shouldRecordTripData: Bool) {
        self.shouldSynchronizeClock = shouldSynchronizeClock
        self.shouldDisplayInCelsius = shouldDisplayInCelsius
        self.isAutostartNaviEnabled = isAutostartNaviEnabled
        self.shouldDisplayInKm = shouldDisplayInKm
        self.shouldSynchronizeData = shouldSynchronizeData
        self.isSafeDrivingEnabled = isSafeDrivingEnabled
        self.shouldEnableAutoFollowMe = shouldEnableAutoFollowMe
        self.shouldRecordTripData = shouldRecordTripData
    }

    static var dummy: UserSettings {
        get {
            return UserSettings(shouldSynchronizeClock: true,
                                shouldDisplayInCelsius: false,
                                isAutostartNaviEnabled: true,
                                shouldDisplayInKm: false,
                                shouldSynchronizeData: true,
                                isSafeDrivingEnabled: false,
                                shouldEnableAutoFollowMe: true,
                                shouldRecordTripData: false)
        }
    }

}
