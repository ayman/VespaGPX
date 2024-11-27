//
//  UserProfile.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/17/24.
//

import Foundation
import SwiftData
import SwiftUICore
import UIKit

@Model
final class UserProfile {
    var id: String = ""
    var avatarData: String = ""

    init(id: String, avatarData: String) {
        self.id = id
        self.avatarData = avatarData
    }

    var avatar: UIImage {
        get {
            if let data = Data(base64Encoded: self.avatarData,
                               options: .ignoreUnknownCharacters) {
                return UIImage(data: data) ?? UIImage()
            }
            return UIImage() // Image(systemName: "person.fill")
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
