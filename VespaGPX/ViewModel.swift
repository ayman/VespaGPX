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

    func decodeJSON(string: String) async {
        guard let decodedData = Data(base64Encoded: string) else { return }
        let jsonString = String(data: decodedData, encoding: .utf8)
        loadTimer = 3.0
        let jsonDecoder = JSONDecoder()
        do {
            let jsonObject = try jsonDecoder.decode(VespaJSON.self,
                                                    from: (jsonString?.data(using: .utf8))!)
            loadTimer = 4.0
            self.platform = jsonObject.header.platform
            self.userId = jsonObject.header.userId
            self.brand = jsonObject.header.brand
            let payloadJson = self.decodePayload(payload: jsonObject.payload)
            loadTimer = 5.0
            self.payload = try jsonDecoder.decode(VespaPayload.self,
                                                  from: (payloadJson.data(using: .utf8))!)
            loadTimer = 6.0
            print("Decoding Finished")
            if let trips = self.payload?.trips {
                self.tripLog = [:]
                self.gpsLog = [:]
                for trip in trips {
                    self.parseTripsCSVs(tripData: trip)
                }
                print("Parsing Finished")
            }
        } catch {
            print(error)
        }
    }

    func decodePayload(payload: String) -> String {
        print("decode")
        guard let decodedData = Data(base64Encoded: payload) else { return "" }
        var json = ""
        do {
            let encoder = try Blowfish(key: Array(self.userId.utf8),
                                       blockMode: ECB(),
                                       padding: .pkcs7)
            let decode = try encoder.decrypt(decodedData)
            json = String(bytes: decode, encoding: .utf8) ?? "fail"
        } catch {
            print(error)
        }
        return json
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

    func parseGpsCSV(gpsData: String) -> [GPSRow] {
        var gps = [GPSRow]()
        var gpsRows = gpsData.components(separatedBy: "\n")
        gpsRows.removeFirst()
        for gRow in gpsRows {
            let columns = gRow.components(separatedBy: ";")
            if columns.count == 4 {
                let newRow = GPSRow(ts: columns[0],
                                    lat: columns[1],
                                    lng: columns[2],
                                    alt: columns[3])
                gps.append(newRow)
            }
        }
        return gps
    }

    func parseTripsCSVs(tripData: VespaTrips) {
        let tData = tripData.tripData
        self.tripLog[tripData.id] = parseTripCSV(tripData: tData)
        self.tripRaw[tripData.id] = tData

        let gData = tripData.tripGPS
        self.gpsLog[tripData.id] = parseGpsCSV(gpsData: gData)
        self.gpsRaw[tripData.id] = gData
    }
}
