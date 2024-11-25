//
//  SimpleRowView.swift
//  VespaGPX
//
//  Created by David A. Shamma on 11/16/24.
//

import SwiftUI

struct SimpleRowView: View {
    let left: String
    let right: String
    let noSpacing: Bool

    init(left: String, right: String, noSpacing: Bool = false) {
        self.left = left
        self.right = right
        self.noSpacing = noSpacing
    }

    var body: some View {
        HStack {
            if !noSpacing {
                Text(self.left)
                    .font(.footnote)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(self.left)
                    .font(.footnote)
                    .bold()
                    .frame(alignment: .leading)
            }
            Spacer()
            Text(self.right)
                .font(.footnote)
                .frame(alignment: .trailing)
        }
        .padding(.horizontal)
    }
}

#Preview {
    SimpleRowView(left: "Foo", right: "Bar")
}
