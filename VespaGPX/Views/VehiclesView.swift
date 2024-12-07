//
//  VehiclesView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/16/24.
//

import SwiftUI
import SwiftData

struct VehiclesView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var vehicles: [Vehicle]

    var body: some View {
        NavigationStack {
            Form {
                ForEach(vehicles) { vehicle in
                    let name = vehicle.name
                    Section(name) {
                        SimpleRowView(left: "batteryVoltage",
                                      right: "\(vehicle.batteryVoltage)")
                        SimpleRowView(left: "engineSize",
                                      right: "\(vehicle.engineSize)")
                        SimpleRowView(left: "id",
                                      right: vehicle.id,
                                      noSpacing: true)
                        SimpleRowView(left: "isAssociated",
                                      right: "\(vehicle.isAssociated)")
                        SimpleRowView(left: "isCelcius",
                                      right: "\(vehicle.isCelsius)")
                        SimpleRowView(left: "lastestUpdate",
                                      right: "\(vehicle.latestUpdate)")
                        SimpleRowView(left: "model",
                                      right: vehicle.model)
                        SimpleRowView(left: "modelId",
                                      right: vehicle.modelId)
                        SimpleRowView(left: "modelYear",
                                      right: "\(vehicle.modelYear)")
                        SimpleRowView(left: "serial",
                                      right: vehicle.serial,
                                      noSpacing: true)
                        SimpleRowView(left: "totalMileage",
                                      right: "\(vehicle.totalMileage)")
                        SimpleRowView(left: "userId",
                                      right: vehicle.userId,
                                      noSpacing: true)
                        SimpleRowView(left: "vin",
                                      right: vehicle.vin,
                                      noSpacing: true)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Text("Vehicles"))
        }
    }
}

#Preview {
    VehiclesView()
        .modelContainer(previewContainer)
}
