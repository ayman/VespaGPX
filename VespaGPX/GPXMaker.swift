//
//  GPXMaker.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/21/24.
//

import Foundation

class GPXMaker {

    private static var gpxHeader: String {
        get {
            return
"""
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="VespaGPX for iOS"
    xmlns="http://www.topografix.com/GPX/1/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd"
    xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"
    xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
    <metadata>
        <name>Vespa Ride</name>
        <type>Motorcycling</type>
    </metadata>
    <trk>

"""
        }
    }

    private static var gpxTrksegStart: String {
        get {
            return
"""
        <trkseg>

"""
        }
    }

    private static var gpxTrkpt: String {
        get {
            // Date format 2018-11-29T08:43:18Z
            return
"""
            <trkpt lat="%@" lon="%@">
                <ele>%@</ele>
                <time>%@</time>
            </trkpt>

"""
        }
    }

    private static var gpxTrksegEnd: String {
        get {
            return
"""
        </trkseg>

"""
        }
    }

    private static var gpxFooter: String {
        get {
            return
"""
    </trk>
</gpx>
"""
        }
    }

    static func getGPX(gpsRows: [GPSRow],
                       addHeadFood: Bool = true) -> String {
        var gpx = ""
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        // let formatter = DateFormatter()
        // formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if addHeadFood {
            gpx += GPXMaker.gpxHeader
            gpx += GPXMaker.gpxTrksegStart
        }
        gpsRows.forEach { row in
            let doubleTime = (Double(row.ts) ?? (Date.now.timeIntervalSince1970 * 1000)) / 1000.0
            let date = Date(timeIntervalSince1970: doubleTime)
            let dateString = formatter.string(from: date)
            gpx += String(format: GPXMaker.gpxTrkpt,
                          row.lat,
                          row.lng,
                          row.alt,
                          dateString)
        }
        if addHeadFood {
            gpx += GPXMaker.gpxTrksegEnd
            gpx += GPXMaker.gpxFooter
        }
        return gpx
    }

    static func mergeGPX(gpsRows: [[GPSRow]]) -> String {
        var gpx = GPXMaker.gpxHeader
        gpx += GPXMaker.gpxTrksegStart
        gpsRows.forEach { collection in
            gpx += GPXMaker.getGPX(gpsRows: collection,
                                   addHeadFood: false)
        }
        gpx += GPXMaker.gpxTrksegEnd
        gpx += GPXMaker.gpxFooter
        return gpx
    }

    static func parseGpsCSV(gpsData: String) -> [GPSRow] {
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

}
