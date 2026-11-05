//
//  VespaGPXTests.swift
//  VespaGPXTests
//
//  Synthetic fixtures: no private Vespa backups, VINs or GPS locations.
//

import Foundation
import CryptoSwift
import Testing
@testable import VespaGPX

struct VespaGPXTests {
    private let syntheticUserId = "synthetic-test-key"

    private var header: [String: Any] {
        ["platform": "iOS", "userId": syntheticUserId, "brand": "Vespa"]
    }

    private var version: [String: Any] {
        ["appVersion": "2.14.2", "platform": "iOS",
         "appName": "Vespa", "platformVersion": "156", "uUID": "synthetic"]
    }

    private var profile: [String: Any] {
        ["id": "synthetic-profile", "avatarData": ""]
    }

    private var preferences: [String: Any] {
        [
            "shouldSynchronizeClock": true, "shouldDisplayInCelsius": true,
            "isAutostartNaviEnabled": false, "shouldDisplayInKm": true,
            "shouldSynchronizeData": true, "isSafeDrivingEnabled": true,
            "shouldEnableAutoFollowMe": false, "shouldRecordTripData": true
        ]
    }

    private var notifications: [String: Any] {
        [
            "findMyBike": false, "genericIssue": false,
            "batteryTips": false, "temperatureBelowZero": false,
            "batteryIssue": false, "lowFuel": false
        ]
    }

    private var vehicle: [String: Any] {
        [
            "name": "Synthetic Test Scooter", "isCelsius": true, "isKm": true,
            "latestUpdate": 0, "id": "synthetic-vehicle", "totalMileage": 100,
            "engineSize": 278, "model": "Synthetic", "vin": "NOT-A-REAL-VIN",
            "modelId": "test", "modelYear": 2026, "batteryVoltage": 12.5,
            "userId": syntheticUserId, "serial": "synthetic", "isAssociated": true
        ]
    }

    private var activity: [String: Any] {
        [
            "avgTripFuelConsumption": 30.0, "id": "synthetic-trip",
            "tractionControlCounter": 0, "endTimestamp": 1002.0,
            "tripLitersConsumed": 0.03, "userId": syntheticUserId,
            "distance": 1.0, "type": "trip", "vehicleId": "synthetic-vehicle",
            "startTimestamp": 1000.0, "duration": 2.0
        ]
    }

    private var trip: [String: Any] {
        [
            "id": "synthetic-trip",
            "tripData": "ts;distance;speed;rpm;consumption;avg_consumption;gas;acceleration;batteryVoltage;EcuWarningLamp;MilLamp;EcuUrgentServiceFlag;oilAlarm;engineTemp;wheelSlip\n1000000;0;0;1800;0;30;0;0;12;0;0;0;0;80;0\n",
            "tripGPS": "ts;lat;lng;alt\n1000000;0;0;0\n"
        ]
    }

    private var records: [(String, Any)] {
        [
            ("userProfile", profile), ("userPreferences", preferences),
            ("userSettings", notifications), ("vehicle", vehicle),
            ("activity", activity), ("trip", trip),
            ("reminder", ["id": "synthetic-reminder"]),
            ("navSaved", [["address": "Synthetic Place", "latitude": 0.0, "longitude": 0.0]]),
            ("navHistory", [["address": "Synthetic Place", "latitude": 0.0, "longitude": 0.0]])
        ]
    }

    private func encrypted(_ value: Any) throws -> String {
        let serialized = try JSONSerialization.data(withJSONObject: value)
        let cipher = try Blowfish(key: Array(syntheticUserId.utf8),
                                  blockMode: ECB(), padding: .pkcs5)
        return Data(try cipher.encrypt(Array(serialized))).base64EncodedString()
    }

    private func stream(footer: Int? = nil, includeFooter: Bool = true) throws -> String {
        let metadata: [String: Any] = [
            "header": header, "versionInfo": version,
            "encrypted": true, "formatVersion": 2
        ]
        let metadataString = String(
            decoding: try JSONSerialization.data(withJSONObject: metadata),
            as: UTF8.self
        )
        var lines = ["#POC-BACKUP-STREAM v2", metadataString]
        for (type, data) in records {
            lines.append(try encrypted(["t": type, "d": data]))
        }
        if includeFooter {
            lines.append(try encrypted(["t": "end", "d": footer ?? records.count]))
        }
        return lines.joined(separator: "\n")
    }

    private func legacy() throws -> String {
        let payload: [String: Any] = [
            "userSettings": preferences, "activities": [activity],
            "trips": [trip], "userProfile": profile, "versionInfo": version,
            "vehicles": [vehicle], "notificationSettings": notifications,
            "reminders": [["id": "synthetic-reminder"]]
        ]
        let cipherText = try encrypted(payload)
        let outer = ["header": header, "payload": cipherText] as [String: Any]
        return try JSONSerialization.data(withJSONObject: outer).base64EncodedString()
    }

    @Test func v2StreamImportsRecords() throws {
        let imported = try VespaBackupImporter.decode(stream())
        #expect(imported.header.userId == syntheticUserId)
        #expect(imported.payload.versionInfo.appVersion == "2.14.2")
        #expect(imported.payload.activities.count == 1)
        #expect(imported.payload.trips.count == 1)
        #expect(imported.payload.trips[0].id == "synthetic-trip")
        #expect(imported.payload.trips[0].tripGPS.contains("1000000;0;0;0"))
        #expect(imported.payload.vehicles.count == 1)
    }

    @Test func legacyBackupStillImports() throws {
        let imported = try VespaBackupImporter.decode(legacy())
        #expect(imported.payload.activities.count == 1)
        #expect(imported.payload.trips.count == 1)
        #expect(imported.payload.userProfile.id == "synthetic-profile")
    }

    @Test func missingEndRecordIsRejected() throws {
        let missingFooter = try stream(includeFooter: false)
        #expect(throws: VespaBackupImporter.ImportError.self) {
            try VespaBackupImporter.decode(missingFooter)
        }
    }

    @Test func incorrectFooterCountIsRejected() throws {
        let incorrectFooter = try stream(footer: 2)
        #expect(throws: VespaBackupImporter.ImportError.self) {
            try VespaBackupImporter.decode(incorrectFooter)
        }
    }
}
