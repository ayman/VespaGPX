//
//  UserProfile.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/17/24.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

@Model
final class UserProfile {
    var id: String = ""
    var avatarData: String = ""

    init(id: String, avatarData: String) {
        self.id = id
        self.avatarData = avatarData
    }

    var avatar: UIImage? {
        get {
            guard !self.avatarData.isEmpty,
                  let data = Data(base64Encoded: self.avatarData,
                                  options: .ignoreUnknownCharacters) else {
                return nil
            }
            return UIImage(data: data)
        }
    }

    static var dummy: UserProfile {
        get {
            let uuid = "50e24348-ace9-11ef-abec-e695dd16660d"
            if let pngData = UIImage(systemName: "person.fill")?.pngData() {
                return UserProfile(id: uuid,
                                   avatarData: pngData.base64EncodedString())
            } else {
                return UserProfile(id: uuid,
                                   avatarData: "")
            }
        }
    }
}
