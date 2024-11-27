//
//  VersionInfo.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/17/24.
//

import Foundation
import SwiftData

@Model
final class VersionInfo {
    var appVersion: String = ""
    var platform: String = ""
    var appName: String = ""
    var platformVersion: String = ""
    var uUID: String = ""

    init(appVersion: String, platform: String, appName: String, platformVersion: String, uUID: String) {
        self.appVersion = appVersion
        self.platform = platform
        self.appName = appName
        self.platformVersion = platformVersion
        self.uUID = uUID
    }

    static var dummy: VersionInfo {
        get {
            return VersionInfo(appVersion: "2.9.5",
                               platform: "iOS",
                               appName: "Vespa",
                               platformVersion: "146",
                               uUID: "3f0e0030-ace9-11ef-abec-e695dd16660d")
        }
    }
}
