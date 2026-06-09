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
    let button: PressedButton
    let isListening: Bool
    let callback: (PressedButton) -> Void

    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).bold()
            Button(isListening ? "Press key..." : binding) {
                callback(button)
            }
            .frame(width: 130)
        }
    }
}
