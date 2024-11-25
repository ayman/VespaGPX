//
//  UserSettings.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/22/24.
//

import Foundation
import WidgetKit

public struct AppSettings {

    public static var shared = AppSettings()

    private var ud: UserDefaults = UserDefaults.standard

//    public var firstRun: Bool {
//        get {
//            return self.ud.bool(forKey: "firstRun")
//        }
//        set (value) {
//            self.ud.set(value, forKey: "firstRun")
//        }
//    }

    public var versionNumber: String {
        get {
            let infoDictionary = Bundle.main.infoDictionary
            let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
            let bundle = infoDictionary?["CFBundleVersion"] as? String ?? "0"
            return "\(version) (\(bundle))"
        }
    }

    public var appName: String {
        get {
            if let name = (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String) {
                return name
            } else {
                return "VespaGPX"
            }
        }
    }
}
