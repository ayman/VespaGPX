//
//  Item.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/14/24.
//

import Foundation
import SwiftData

@Model
final class Activity: Identifiable {
    // let totalEarnedKm: null
    var avgTripFuelConsumption: Double
    var id: String
    var tractionControlCounter: Int
    var endTimestamp: Double
    // let avgAcceleration: null
    var tripLitersConsumed: Double
    var userId: String
    var distance: Double
    // let tripRecoveredEnergy: null
    // let avgTripEnergyConsumption: null
    // let emittedCO2: null,
    var type: String
    var vehicleId: String
    var startTimestamp: Double
    // let tripConsGPL: null
    // let totalRecoveredEnergy: null
    var duration: Double
    var tripData: String
    var gpsData: String

    init(avgTripFuelConsumption: Double, id: String, tractionControlCounter: Int, endTimestamp: Double, tripLitersConsumed: Double, userId: String, distance: Double, type: String, vehicleId: String, startTimestamp: Double, duration: Double, tripData: String, gpsData: String) {
        self.avgTripFuelConsumption = avgTripFuelConsumption
        self.id = id
        self.tractionControlCounter = tractionControlCounter
        self.endTimestamp = endTimestamp
        self.tripLitersConsumed = tripLitersConsumed
        self.userId = userId
        self.distance = distance
        self.type = type
        self.vehicleId = vehicleId
        self.startTimestamp = startTimestamp
        self.duration = duration
        self.tripData = tripData
        self.gpsData = gpsData
    }

    var timestamp: Double {
        get {
            return Double(String(self.id.suffix(self.id.count - 5))) ?? 0.0
        }
    }

    static var dummy: Activity {
        get {
            return Activity(avgTripFuelConsumption: 10.1473371386016,
                            id: "trip_1716775140129",
                            tractionControlCounter: 0,
                            endTimestamp: 738467940.129134,
                            tripLitersConsumed: 0.0993080728865332,
                            userId: UserProfile.dummy.id,
                            distance: 1.00771249616447,
                            type: "trip",
                            vehicleId: Vehicle.dummy.id,
                            startTimestamp: 738467466.518744,
                            duration: 473.610751986504,
                            tripData: "",
                            gpsData: "")
        }
    }
}
