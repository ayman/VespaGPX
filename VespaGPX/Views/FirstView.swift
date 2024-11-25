//
//  FirstView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/22/24.
//

import SwiftUI

struct FirstView: View {
    var body: some View {
        VStack {
            Text("Looks like you haven't loaded any data yet! In the Vespa app settings, \(Text("Export a JSON file").bold().italic()) using the Vehicle Backup tool.  Then, you can \(Text("Load the JSON").bold().italic()) here by tapping in the button.")
                .padding()
            DownloadButton()
        }
    }
}

#Preview {
    FirstView()
}
