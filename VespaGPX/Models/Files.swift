//
//  Files.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/22/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CSVFile: Transferable {
    public var fileName: String
    public var content: String

    // static var readableContentTypes: [UTType] = [.csv]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .delimitedText) {
            $0.convertToData()
        }
        .suggestedFileName { $0.fileName }
    }

    func convertToData() -> Data {
        return self.content.data(using: .ascii) ?? Data()
    }
}

struct GPXFile: Transferable {
    public var fileName: String
    public var content: String

    // static var readableContentTypes: [UTType] = [.gpx]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .gpx) {
            $0.convertToData()
        }
        .suggestedFileName { $0.fileName }
    }

    func convertToData() -> Data {
        return self.content.data(using: .utf8) ?? Data()
    }
}

extension UTType {
    static var gpx: UTType = UTType(exportedAs: "ai.shamur.gpx")
    static var csv: UTType = UTType(exportedAs: "ai.shamur.csv")
}
