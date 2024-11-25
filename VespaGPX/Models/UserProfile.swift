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
                print(avatarData)
                return UIImage(data: data) ?? UIImage()
//                return Image(uiImage: image ?? UIImage())
//                    .resizable()
//                    .ignoresSafeArea()
//                    .aspectRatio(contentMode: .fill) as! Image
            }
            return UIImage() // Image(systemName: "person.fill")
        }
    }
}
