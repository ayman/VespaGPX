//
//  LoadingView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/22/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView("Loading JSON...").controlSize(.large).tint(.accentColor)
            .padding()
            // .ignoresSafeArea()
            // .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}

#Preview {
    LoadingView()
}
