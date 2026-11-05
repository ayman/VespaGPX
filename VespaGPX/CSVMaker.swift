//
//  CSVMaker.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/23/24.
//

import Foundation

class CSVMaker {
    static func merge(names: [String], csvFiles: [String]) -> String {
        if csvFiles.isEmpty {
            return ""
        }

        var output = ""
        var first = csvFiles[0]
        first = "id;" + first
        let firstRows = first.components(separatedBy: "\n")
        output += firstRows[0] + "\n"
        for firstCounter in 1...(firstRows.count - 1) {
            output += "\(names[0]);\(firstRows[firstCounter])\n"
        }

        if csvFiles.count == 1 {
            return output.replacingOccurrences(of: ";",
                                               with: ",")
        }

        for counter in 1...(csvFiles.count - 1) {
            let data = csvFiles[counter]
            var dataRows = data.components(separatedBy: "\n")
            dataRows.removeFirst()
            dataRows.forEach { line in
                output += "\(names[counter]);\(line)\n"
            }
        }

        return output.replacingOccurrences(of: ";",
                                           with: ",")
    }
}


// A single row per telemetry sample. GPS fixes are matched by timestamp
// rather than row number, and a GPS fix cannot be reused for multiple samples.
extension CSVMaker {
    static func combineGPSAndTelemetry(tripData: String, gpsData: String) -> String {
        let telemetryLines = tripData.split(whereSeparator: \.isNewline).map(String.init)
        guard let firstLine = telemetryLines.first else { return "" }
        let headers = firstLine.components(separatedBy: ";")
        guard headers.count >= 2,
              headers[0].trimmingCharacters(in: .whitespacesAndNewlines) == "ts" else {
            return ""
        }

        let gpsSamples = GPXMaker.parseGpsCSV(gpsData: gpsData).compactMap { row -> (timestamp: Double, latitude: String, longitude: String, altitude: String)? in
            guard let timestamp = Double(row.ts), timestamp.isFinite,
                  let latitude = Double(row.lat), latitude.isFinite, (-90.0...90.0).contains(latitude),
                  let longitude = Double(row.lng), longitude.isFinite, (-180.0...180.0).contains(longitude) else {
                return nil
            }
            return (timestamp, row.lat, row.lng, row.alt)
        }.sorted { $0.timestamp < $1.timestamp }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let combinedHeaders = ["timestamp_utc", "ts", "latitude", "longitude", "altitude"]
            + Array(headers.dropFirst())
        var output = [combinedHeaders.map(csvEscape).joined(separator: ",")]
        var gpsCursor = 0
        // The original app samples both streams around once per second.
        // Require a close fix instead of inventing coordinates across GPS gaps.
        let maximumDifferenceMs = 750.0

        for line in telemetryLines.dropFirst() {
            let fields = line.components(separatedBy: ";")
            guard fields.count == headers.count else { continue }

            var timestampUTC = ""
            var gpsFields = ["", "", ""]

            if let telemetryTimestamp = Double(fields[0]), telemetryTimestamp.isFinite {
                timestampUTC = dateFormatter.string(
                    from: Date(timeIntervalSince1970: telemetryTimestamp / 1000.0)
                )

                while gpsCursor < gpsSamples.count
                    && gpsSamples[gpsCursor].timestamp < telemetryTimestamp - maximumDifferenceMs {
                    gpsCursor += 1
                }

                var closestIndex: Int?
                var closestDifference = Double.infinity
                var candidate = gpsCursor
                while candidate < gpsSamples.count
                    && gpsSamples[candidate].timestamp <= telemetryTimestamp + maximumDifferenceMs {
                    let difference = abs(gpsSamples[candidate].timestamp - telemetryTimestamp)
                    if difference < closestDifference {
                        closestDifference = difference
                        closestIndex = candidate
                    }
                    candidate += 1
                }

                if let closestIndex {
                    let gps = gpsSamples[closestIndex]
                    gpsFields = [gps.latitude, gps.longitude, gps.altitude]
                    gpsCursor = closestIndex + 1
                }
            }

            let combined = [timestampUTC, fields[0]] + gpsFields + Array(fields.dropFirst())
            output.append(combined.map(csvEscape).joined(separator: ","))
        }

        return output.joined(separator: "\n") + "\n"
    }

    private static func csvEscape(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"")
                || value.contains("\n") || value.contains("\r") else {
            return value
        }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
