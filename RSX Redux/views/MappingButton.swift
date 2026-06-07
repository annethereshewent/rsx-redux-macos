//
//  MappingButton.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/6/26.
//

import SwiftUI

struct MappingButton: View {
    let title: String
    let binding: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).bold()
            Button(binding) {

            }
            .frame(width: 130)
        }
    }
}
