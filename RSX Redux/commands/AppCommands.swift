//
//  AppCommands.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/3/26.
//

import SwiftUI
import SwiftData

struct AppCommands: Commands {
    @Environment(\.modelContext) private var context
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Query private var games: [Game]

    @ObservedObject var emulatorCore: EmulatorCore
    @Binding var currentBiosUrl: URL?
    @Binding var currentGame: Game?
    @Binding var initialize: Bool
    @Binding var showDialog: Bool
    @Binding var fileType: FileType?

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Menu("Open Recent") {
                ForEach(games, id: \.gameName) { game in
                    Button(game.gameName) {
                        if let biosUrl = currentBiosUrl {
                            var stale = false
                            do {
                                let url = try URL(
                                    resolvingBookmarkData: game.bookmark,
                                    options: [.withSecurityScope],
                                    relativeTo: nil,
                                    bookmarkDataIsStale: &stale
                                )

                                currentGame = game

                                emulatorCore.isRunning = false
                                emulatorCore.initialize()
                                emulatorCore.loadBios(biosUrl: biosUrl)
                                emulatorCore.startEmulator(gameUrl: url)
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
            .disabled(!emulatorCore.biosLoaded)
        }
        CommandGroup(after: .newItem) {
            Button("New Game") {
                initialize = true
                showDialog = true
                fileType = .disc
            }
            .keyboardShortcut("o", modifiers: [.command])
            .disabled(!emulatorCore.biosLoaded)
        }
        CommandGroup(after: .newItem) {
            Button("Load Disc (for current game)") {
                initialize = false
                showDialog = true
                fileType = .disc
            }
            .disabled(!emulatorCore.isRunning)
        }
        CommandGroup(after: .newItem) {
            Button("Load Bios") {
                showDialog = true
                fileType = .bios
            }
        }
        CommandGroup(after: .newItem) {
            Button("Load State") {
                openWindow(id: "save_states")
            }
            .keyboardShortcut("l", modifiers: [.command])
            .disabled(currentGame == nil)

        }
        CommandGroup(after: .newItem) {
            Menu("Save State") {
                let saveStates = currentGame?.saveStates ?? []
                ForEach(saveStates.sorted(by: { $0.saveName < $1.saveName }), id: \.saveName) { saveState in
                    Button(saveState.saveName) {
                        if let saveState = emulatorCore.saveState(saveState: saveState, saveNumber: nil) {
                            context.insert(saveState)
                        }
                    }
                }
                Button("Create New State") {
                    if let newState = emulatorCore.saveState(saveState: nil, saveNumber: saveStates.count + 1) {
                        context.insert(newState)
                    }
                }

            }
            .disabled(currentGame == nil || !emulatorCore.isRunning)
            .keyboardShortcut("s", modifiers: [.command])
        }
        CommandGroup(after: .toolbar) {
            Button("Waveform Visualizer") {
                emulatorCore.showWaveForm.toggle()
            }
        }
    }
}
