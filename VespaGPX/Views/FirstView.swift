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
            Text("Welcome to VespaGPX").font(.title)
            Text("""
                 To use this app, you'll need to be using the [Vespa ](https://apps.apple.com/us/app/vespa/id1389278133) iOS app to track your rides.  You'll need to manually backup the data by going in the Vespa app to:
                 """)
            .padding()
            Text("Settings ➡ Backup ➡ Export").monospaced()
                .padding()
            Text("""
                 Once you've exported from the Vespa app, you can load the exported JSON file into here and export whatever trips you like as GPX or CSV!
                 """)
                .padding()
            DownloadButton()
        }
    }
}

#Preview {
    FirstView()
        .environmentObject(ViewModel())
}
