//
//  Untitled.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/15/24.
//

import Foundation
import SwiftData

struct VespaJSON: Decodable {
    let header: VespaHeader
    let payload: String
}

struct VespaHeader: Decodable {
    let platform: String
    let userId: String
    let brand: String
}

struct VespaPayload: Decodable {
    let userSettings: VespaUserSettings
    let activities: [VespaActivities]
    let trips: [VespaTrips]
    let userProfile: VespaUserProfile
    let versionInfo: VespaVersionInfo
    let vehicles: [VespaVehicle]
    let notificationSettings: VespaNotificationSettings
    let reminders: [VespaReminders]
}

struct VespaUserSettings: Decodable {
    let shouldSynchronizeClock: Bool
    let shouldDisplayInCelsius: Bool
    let isAutostartNaviEnabled: Bool
    let shouldDisplayInKm: Bool
    let shouldSynchronizeData: Bool
    let isSafeDrivingEnabled: Bool
    let shouldEnableAutoFollowMe: Bool
    let shouldRecordTripData: Bool
}

struct VespaActivities: Decodable {
    // let totalEarnedKm: null
    let avgTripFuelConsumption: Double
    let id: String
    let tractionControlCounter: Int
    let endTimestamp: Double
    // let avgAcceleration: null
    let tripLitersConsumed: Double
    let userId: String
    let distance: Double
    // let tripRecoveredEnergy: null
    // let avgTripEnergyConsumption: null
    // let emittedCO2: null,
    let type: String
    let vehicleId: String
    let startTimestamp: Double
    // let tripConsGPL: null
    // let totalRecoveredEnergy: null
    let duration: Double
}

struct VespaTrips: Decodable {
    let id: String
    let tripData: String // ts;distance;speed;rpm;consumption;avg_consumption;gas;acceleration;batteryVoltage;EcuWarningLamp;MilLamp;EcuUrgentServiceFlag;oilAlarm;engineTemp;wheelSlip
    let tripGPS: String // ts;lat;lng;alt
}

struct VespaUserProfile: Decodable {
    let id: String
    let avatarData: String
}

struct VespaVehicle: Decodable, Identifiable {
    let name: String
    let isCelsius: Bool
    let isKm: Bool
    let latestUpdate: Int
    let id: String
    let totalMileage: Int
    let engineSize: Int
    let model: String
    let vin: String
    let modelId: String
    let modelYear: Int
    let batteryVoltage: Double
    let userId: String
    let serial: String
    let isAssociated: Bool
}

struct VespaNotificationSettings: Decodable {
    let findMyBike: Bool
    let genericIssue: Bool
    let batteryTips: Bool
    let temperatureBelowZero: Bool
    let batteryIssue: Bool
    let lowFuel: Bool
}

struct VespaReminders: Decodable {

}

struct VespaVersionInfo: Decodable {
    let appVersion: String
    let platform: String
    let appName: String
    let platformVersion: String
    let uUID: String
}
