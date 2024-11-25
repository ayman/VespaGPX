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
<gpx xmlns="http://www.topografix.com/GPX/1/1" version="1.1" creator="VespaGPX for iOS">
    <trk>
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

    private static var gpxFooter: String {
        get {
            return
"""
        </trkseg>
    </trk>
</gpx>
"""
        }
    }

    static func getGPX(gpsRows: [GPSRow],
                       addHeadFood: Bool = true) -> String {
        var gpx = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if addHeadFood {
            gpx += GPXMaker.gpxHeader
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
            gpx += GPXMaker.gpxFooter
        }
        return gpx
    }

    static func mergeGPX(gpsRows: [[GPSRow]]) -> String {
        var gpx = GPXMaker.gpxHeader
        gpsRows.forEach { collection in
            gpx += GPXMaker.getGPX(gpsRows: collection,
                                   addHeadFood: false)
        }
        gpx += GPXMaker.gpxFooter
        return gpx
    }

}
