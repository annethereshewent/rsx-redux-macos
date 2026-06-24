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
    @Binding var isSwap: Bool
    @Binding var showDialog: Bool
    @Binding var fileType: FileType?

    private var sortedGames: [Game] {
        let sortedGames = games.sorted {
            $0.lastPlayed > $1.lastPlayed
        }

        return Array(sortedGames.prefix(10))
    }

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Menu("Open Recent") {
                ForEach(sortedGames, id: \.gameName) { game in
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

                                game.lastPlayed = Date()

                                try? context.save()

                                currentGame = game

                                emulatorCore.stopEmulatorThen {
                                    emulatorCore.initialize()
                                    emulatorCore.loadBios(biosUrl: biosUrl)
                                    if url.pathExtension == "exe" {
                                        emulatorCore.startExe(exeUrl: url)
                                    } else {
                                        Task {
                                            await emulatorCore.startEmulator(gameUrl: url)
                                        }
                                    }
                                }
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
            Button("Open") {
                initialize = true
                showDialog = true
                isSwap = false
                fileType = .disc
            }
            .keyboardShortcut("o", modifiers: [.command])
            .disabled(!emulatorCore.biosLoaded)
        }
        CommandGroup(after: .newItem) {
            Button("Swap disc") {
                emulatorCore.openShell()
                initialize = false
                showDialog = true
                isSwap = true
                fileType = .disc
            }
            .disabled(currentGame == nil)
        }
        CommandGroup(after: .newItem) {
            Button("Load Bios") {
                showDialog = true
                fileType = .bios
            }
            .disabled(currentGame != nil)
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
                        if let stateInfo = emulatorCore.saveState() {
                            saveState.timestamp = Int(Date().timeIntervalSince1970)
                            saveState.saveData = stateInfo.saveData
                            saveState.screenshot = stateInfo.screenshot
                            saveState.imageWidth = stateInfo.width
                            saveState.imageHeight = stateInfo.height

                            context.insert(saveState)
                        }
                    }
                }
                Button("Create New State") {
                    if let stateInfo = emulatorCore.saveState() {
                        let saveName = "Save State \(currentGame!.saveStates!.count + 1)"
                        let saveState = SaveState(
                            saveName: saveName,
                            screenshot: stateInfo.screenshot,
                            imageWidth: stateInfo.width,
                            imageHeight: stateInfo.height,
                            saveData: stateInfo.saveData,
                            timestamp: Int(Date().timeIntervalSince1970)
                        )
                        currentGame!.saveStates?.append(saveState)
                        context.insert(saveState)
                    }
                }

            }
            .disabled(currentGame == nil)
            .keyboardShortcut("s", modifiers: [.command])
        }
        CommandGroup(after: .toolbar) {
            Button("Waveform Visualizer") {
                emulatorCore.showWaveForm.toggle()
            }
        }
    }
}
