//
//  ActivityView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/16/24.
//

import Foundation
import SwiftUI

struct ActivityRowView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext

    let item: Activity

    var body: some View {
        let distance = String(format: "%.1f", item.distance)
        let duration = String(format: "%.0f", item.duration * 0.01)
        let startTime = String(item.id.suffix(item.id.count - 5))
        HStack {
            VStack {
                Text(makeDateSting(timestamp: startTime))
                    .font(.callout)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(self.item.id)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
//                Text(makeDateSting(timestamp: startTime, offset: item.duration))
//                    .font(.callout)
//                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            VStack {
                Text("\(distance) km")
                    .font(.caption2)
                    .frame(alignment: .trailing)
                Text("\(duration) min")
                    .font(.caption2)
                    .frame(alignment: .trailing)
            }
            .frame(alignment: .trailing)
        }
    }

    func makeDateSting(timestamp: String, offset: Double = 0.0) -> String {
        guard var number = Double(timestamp) else { return "" }
        number = (number * 0.001) + offset
        let date = Date(timeIntervalSince1970: number)
        let formatter = DateFormatter()
        // formatter.setLocalizedDateFormatFromTemplate("EEEMMMddyyyy HH:mm")
        formatter.formatterBehavior = .behavior10_4
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ActivityRowView(item: Activity.dummy)
}
