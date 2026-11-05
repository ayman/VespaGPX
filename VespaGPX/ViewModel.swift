//
//  ContentViewModel.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/15/24.
//

import Foundation
import CryptoSwift

// @Observable
class ViewModel: ObservableObject {
    @Published var downloading = false
    var platform: String = ""
    var userId: String = ""
    var brand: String = ""
    var payload: VespaPayload?
    var loadTimer: Double = 0.0
    var tripLog: [String: [TripRow]] = [:]
    var gpsLog: [String: [GPSRow]] = [:]
    var tripRaw: [String: String] = [:]
    var gpsRaw: [String: String] = [:]

    func decodeJSON(string: String) async throws {
        // Parse fully before replacing any existing data.
        let imported = try VespaBackupImporter.decode(string)
        self.platform = imported.header.platform
        self.userId = imported.header.userId
        self.brand = imported.header.brand
        self.payload = imported.payload
        self.tripLog = [:]
        self.gpsLog = [:]
        self.tripRaw = [:]
        self.gpsRaw = [:]
        loadTimer = 5.0

        for trip in imported.payload.trips {
            self.parseTripsCSVs(tripData: trip)
        }
        loadTimer = 6.0

        // Piaggio's exporter can omit full trip records without an invalid footer.
        // Retain the activity rather than silently discarding it.
        let tripIds = Set(imported.payload.trips.map(\.id))
        let missing = imported.payload.activities.filter { !tripIds.contains($0.id) }.count
        if missing > 0 {
            print("Vespa backup imported with \(missing) activities missing detailed trip data.")
        }
    }

    func parseTripCSV(tripData: String) -> [TripRow] {
        var trip = [TripRow]()
        var tripRows = tripData.components(separatedBy: "\n")
        tripRows.removeFirst()
        for tRow in tripRows {
            let columns = tRow.components(separatedBy: ";")
            if columns.count == 15 {
                let newRow = TripRow(ts: columns[0],
                                     distance: columns[1],
                                     speed: columns[2],
                                     rpm: columns[3],
                                     consumption: columns[4],
                                     avg_consumption: columns[5],
                                     gas: columns[6],
                                     acceleration: columns[7],
                                     batteryVoltage: columns[8],
                                     EcuWarningLamp: columns[9],
                                     MilLamp: columns[10],
                                     EcuUrgentServiceFlag: columns[11],
                                     oilAlarm: columns[12],
                                     engineTemp: columns[13],
                                     wheelSlip: columns[14])
                trip.append(newRow)
            }
        }
        return trip
    }

    func parseTripsCSVs(tripData: VespaTrips) {
        let tData = tripData.tripData
        self.tripLog[tripData.id] = parseTripCSV(tripData: tData)
        self.tripRaw[tripData.id] = tData

        let gData = tripData.tripGPS
        self.gpsLog[tripData.id] = GPXMaker.parseGpsCSV(gpsData: gData)
        self.gpsRaw[tripData.id] = gData
    }
}


/// Imports original Vespa backups and the v2 record stream added in app 2.14.0.
/// Every encrypted v2 record must decrypt, and its end-count must be valid.
enum VespaBackupImporter {
    enum ImportError: LocalizedError {
        case invalidFormat
        case invalidStreamHeader
        case unsupportedStream
        case invalidRecord(Int)
        case unexpectedRecordType(String)
        case missingFooter
        case recordCountMismatch(expected: Int, actual: Int)
        case dataAfterFooter

        var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "This file is not a supported Vespa backup."
            case .invalidStreamHeader:
                return "The Vespa backup stream header is invalid."
            case .unsupportedStream:
                return "This Vespa backup stream version is not supported."
            case .invalidRecord(let line):
                return "The Vespa backup contains an invalid record at line \(line)."
            case .unexpectedRecordType(let type):
                return "The Vespa backup contains an unsupported record type: \(type)."
            case .missingFooter:
                return "This Vespa backup is incomplete: the end record is missing."
            case .recordCountMismatch(let expected, let actual):
                return "Vespa backup record-count mismatch: expected \(expected), found \(actual)."
            case .dataAfterFooter:
                return "The Vespa backup contains data after its end record."
            }
        }
    }

    static func decode(_ source: String) throws -> (header: VespaHeader, payload: VespaPayload) {
        if source.hasPrefix("#POC-BACKUP-STREAM") {
            return try decodeStream(source)
        }
        return try decodeLegacy(source)
    }

    private static func decodeLegacy(_ source: String) throws -> (header: VespaHeader, payload: VespaPayload) {
        guard let decodedData = Data(base64Encoded: source.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw ImportError.invalidFormat
        }
        let original = try JSONDecoder().decode(VespaJSON.self, from: decodedData)
        let decrypted = try decrypt(original.payload, using: original.header.userId)
        let payload = try JSONDecoder().decode(VespaPayload.self, from: decrypted)
        return (original.header, payload)
    }

    private static func decodeStream(_ source: String) throws -> (header: VespaHeader, payload: VespaPayload) {
        let lines = source.components(separatedBy: .newlines)
        guard lines.count >= 3, lines[0] == "#POC-BACKUP-STREAM v2",
              let metadataData = lines[1].data(using: .utf8),
              let metadata = try JSONSerialization.jsonObject(with: metadataData) as? [String: Any],
              let headerObject = metadata["header"] as? [String: Any],
              let userId = headerObject["userId"] as? String, !userId.isEmpty,
              let versionInfo = metadata["versionInfo"] as? [String: Any] else {
            throw ImportError.invalidStreamHeader
        }
        guard metadata["formatVersion"] as? Int == 2,
              metadata["encrypted"] as? Bool == true else {
            throw ImportError.unsupportedStream
        }

        let headerData = try JSONSerialization.data(withJSONObject: headerObject)
        let header = try JSONDecoder().decode(VespaHeader.self, from: headerData)
        var payloadObject: [String: Any] = [
            "vehicles": [Any](),
            "userSettings": [String: Any](),
            "reminders": [Any](),
            "userProfile": [String: Any](),
            "versionInfo": versionInfo,
            "activities": [Any](),
            "trips": [Any](),
            "notificationSettings": [String: Any](),
            "navigatorSavedPlace": [Any](),
            "navigatorHistoryPlace": [Any]()
        ]

        var count = 0
        var foundEnd = false
        for (offset, rawLine) in lines.dropFirst(2).enumerated() {
            let lineNumber = offset + 3
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }
            if foundEnd { throw ImportError.dataAfterFooter }
            guard let decrypted = try? decrypt(line, using: userId),
                  let record = try? JSONSerialization.jsonObject(with: decrypted) as? [String: Any],
                  let type = record["t"] as? String,
                  let data = record["d"] else {
                throw ImportError.invalidRecord(lineNumber)
            }

            if type == "end" {
                guard let expected = data as? Int else { throw ImportError.invalidRecord(lineNumber) }
                guard expected == count else {
                    throw ImportError.recordCountMismatch(expected: expected, actual: count)
                }
                foundEnd = true
                continue
            }

            switch type {
            case "vehicle", "activity", "trip", "reminder":
                guard data is [String: Any] else { throw ImportError.invalidRecord(lineNumber) }
                let key: String
                switch type {
                case "vehicle": key = "vehicles"
                case "activity": key = "activities"
                case "trip": key = "trips"
                default: key = "reminders"
                }
                var list = payloadObject[key] as? [Any] ?? []
                list.append(data)
                payloadObject[key] = list
            case "userProfile":
                guard data is [String: Any] else { throw ImportError.invalidRecord(lineNumber) }
                payloadObject["userProfile"] = data
            case "userPreferences":
                guard data is [String: Any] else { throw ImportError.invalidRecord(lineNumber) }
                payloadObject["userSettings"] = data
            case "userSettings":
                guard data is [String: Any] else { throw ImportError.invalidRecord(lineNumber) }
                payloadObject["notificationSettings"] = data
            case "navSaved", "navHistory":
                let key = type == "navSaved" ? "navigatorSavedPlace" : "navigatorHistoryPlace"
                var list = payloadObject[key] as? [Any] ?? []
                if let places = data as? [Any] {
                    list.append(contentsOf: places)
                } else {
                    list.append(data)
                }
                payloadObject[key] = list
            default:
                throw ImportError.unexpectedRecordType(type)
            }
            count += 1
        }

        guard foundEnd else { throw ImportError.missingFooter }
        let payloadData = try JSONSerialization.data(withJSONObject: payloadObject)
        let payload = try JSONDecoder().decode(VespaPayload.self, from: payloadData)
        return (header, payload)
    }

    private static func decrypt(_ base64: String, using userId: String) throws -> Data {
        guard let encrypted = Data(base64Encoded: base64) else {
            throw ImportError.invalidFormat
        }
        let cipher = try Blowfish(key: Array(userId.utf8), blockMode: ECB(), padding: .pkcs5)
        return Data(try cipher.decrypt(Array(encrypted)))
    }
}
