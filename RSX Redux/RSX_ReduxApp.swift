//
//  RSX_ReduxApp.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import SwiftData
import GoogleSignIn

enum FileType {
    case disc
    case bios
}

@main
struct RSX_ReduxApp: App {
    @StateObject private var emulatorCore = EmulatorCore()
    @State private var showDialog = false
    @State private var currentDiscUrl: URL?
    @State private var currentBiosUrl: URL?
    @State private var fileType: FileType?
    @State private var initialize = false
    @State private var isSwap = false
    @State private var currentGame: Game?
    @State private var user: GIDGoogleUser?

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some Scene {
        WindowGroup {
            ContentView(
                currentDiscUrl: $currentDiscUrl,
                currentBiosUrl: $currentBiosUrl,
                initialize: $initialize,
                isSwap: $isSwap,
                currentGame: $currentGame,
                showDialog: $showDialog,
                fileType: $fileType,
                user: $user
            )
                .environmentObject(emulatorCore)
                .onAppear {
                    emulatorCore.initialize()

                    if var location = try? FileManager.default.url(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true
                    ) {
                        location.appendPathComponent("RSX Redux", isDirectory: true)

                        if let biosUrl = URL(string: "bios.bin", relativeTo: location) {
                            if FileManager.default.fileExists(atPath: biosUrl.path) {
                                currentBiosUrl = biosUrl
                                emulatorCore.loadBios(biosUrl: biosUrl)
                            }
                        }
                    }
                }
                .onChange(of: emulatorCore.showWaveForm) {
                    if emulatorCore.showWaveForm {
                        openWindow(id: "waveform")
                    } else {
                        dismissWindow(id: "waveform")
                    }
                }
        }
        .commands {
            AppCommands(
                emulatorCore: emulatorCore,
                currentBiosUrl: $currentBiosUrl,
                currentGame: $currentGame,
                initialize: $initialize,
                isSwap: $isSwap,
                showDialog: $showDialog,
                fileType: $fileType
            )
        }
        .modelContainer(for: [Game.self, SaveState.self])


        Window("Waveform Visualizer", id: "waveform") {
            StereoWaveformView(model: emulatorCore.waveFormModel)
                .frame(minWidth: 600, minHeight: 240)
                .environmentObject(emulatorCore)
                .onDisappear {
                    emulatorCore.showWaveForm = false
                }
        }
        Window("Save States", id: "save_states") {
            SaveStateView(currentGame: $currentGame)
                .environmentObject(emulatorCore)
        }
        .modelContainer(for: [Game.self, SaveState.self])

        Settings {
            SettingsView(currentGame: $currentGame, user: $user)
                .environmentObject(emulatorCore)
                .frame(width: 1280, height: 960)
        }
    }

}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
