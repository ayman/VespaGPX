//
//  CSVMaker.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/23/24.
//

import Foundation

class CSVMaker {
    static func mergeGPX(names: [String], csvFiles: [String]) -> String {
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
