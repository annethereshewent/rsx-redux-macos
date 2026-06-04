//
//  SaveStateView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/3/26.
//

import SwiftUI

struct SaveStateView: View {
    @Binding var currentGame: Game?
    @EnvironmentObject private var emulatorCore: EmulatorCore

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 200))
                ],
                spacing: 16
            ) {
                let saveStates = currentGame?.saveStates ?? []
                ForEach(saveStates) { saveState in
                    let nsImage = NSImage(data: saveState.screenshot) ?? NSImage()
                    Button() {
                        emulatorCore.loadState(data: saveState.saveData)
                    } label: {
                        VStack {
                            Image(nsImage: nsImage)
                            Text(saveState.saveName)
                        }
                    }

                }
            }
        }
    }
}
