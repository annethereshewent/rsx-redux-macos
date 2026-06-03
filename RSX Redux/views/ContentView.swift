//
//  ContentView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var emulatorCore: EmulatorCore

    @Binding var currentDiscUrl: URL?
    @Binding var currentBiosUrl: URL?

    var body: some View {
        EmulatorView()
            .aspectRatio(4/3, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .onAppear {

            }
            .onChange(of: currentDiscUrl) {
                if let url = currentDiscUrl {
                    emulatorCore.startEmulator(gameUrl: url)
                }
            }
            .onChange(of: currentBiosUrl) {
                if let url = currentBiosUrl {
                    emulatorCore.loadBios(biosUrl: url)
                }
            }
    }
}
