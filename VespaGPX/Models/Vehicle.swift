//
//  Vehicle.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/17/24.
//

import Foundation
import SwiftData

@Model
final class Vehicle: Identifiable {
    var name: String
    var isCelsius: Bool
    var isKm: Bool
    var latestUpdate: Int
    var id: String
    var totalMileage: Int
    var engineSize: Int
    var model: String
    var vin: String
    var modelId: String
    var modelYear: Int
    var batteryVoltage: Double
    var userId: String
    var serial: String
    var isAssociated: Bool

    init(name: String, isCelsius: Bool, isKm: Bool, latestUpdate: Int, id: String, totalMileage: Int, engineSize: Int, model: String, vin: String, modelId: String, modelYear: Int, batteryVoltage: Double, userId: String, serial: String, isAssociated: Bool) {
        self.name = name
        self.isCelsius = isCelsius
        self.isKm = isKm
        self.latestUpdate = latestUpdate
        self.id = id
        self.totalMileage = totalMileage
        self.engineSize = engineSize
        self.model = model
        self.vin = vin
        self.modelId = modelId
        self.modelYear = modelYear
        self.batteryVoltage = batteryVoltage
        self.userId = userId
        self.serial = serial
        self.isAssociated = isAssociated
    }

    static var dummy: Vehicle {
        get {
            return Vehicle(name: "GTS 300 Super Sport",
                           isCelsius: false,
                           isKm: false,
                           latestUpdate: 1716672425965,
                           id: "2309406069516660",
                           totalMileage: 36,
                           engineSize: 300,
                           model: "GTS 300 My22",
                           vin: "acea11efabece695d",
                           modelId: "gts_300_hella",
                           modelYear: 2024,
                           batteryVoltage: 12.4,
                           userId: UserProfile.dummy.id,
                           serial: "000e2878-acea-11ef-abec-e695dd16660d",
                           isAssociated: true)
        }
    }
}
