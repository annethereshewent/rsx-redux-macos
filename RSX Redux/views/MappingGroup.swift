//
//  MappingGroup.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/6/26.
//

import SwiftUI

struct MappingGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        GroupBox(title) {
            content
                .padding(8)
        }
    }
}
