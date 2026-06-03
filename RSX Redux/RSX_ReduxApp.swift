//
//  RSX_ReduxApp.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let binType = UTType(filenameExtension: "bin", conformingTo: .data)

    func storeBios(location: URL, data: Data) -> URL? {
        let appPath = location.appendingPathComponent("RSX Redux", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: appPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription);
        }

        if let url = URL(string: "bios.bin", relativeTo: appPath) {
            try! data.write(to: url)

            return url
        }

        return nil
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                currentDiscUrl: $currentDiscUrl,
                currentBiosUrl: $currentBiosUrl
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
                            currentBiosUrl = biosUrl
                            emulatorCore.loadBios(biosUrl: biosUrl)
                        }
                    }
                }
                .fileImporter(isPresented: $showDialog, allowedContentTypes: [binType!] ) { result in
                    if let url = try? result.get() {
                        switch fileType {
                        case .bios:
                            if let location = try? FileManager.default.url(
                                for: .applicationSupportDirectory,
                                in: .userDomainMask,
                                appropriateFor: nil,
                                create: true
                            ) {
                                if url.startAccessingSecurityScopedResource() {
                                    defer { url.stopAccessingSecurityScopedResource() }
                                    if let data = try? Data(contentsOf: url) {
                                        currentBiosUrl = storeBios(location: location, data: data)
                                    }
                                }

                            }
                            break
                        case .disc:
                            if emulatorCore.isRunning && initialize {
                                if let biosUrl = currentBiosUrl {
                                    emulatorCore.isRunning = false
                                    emulatorCore.initialize()
                                    emulatorCore.loadBios(biosUrl: biosUrl)
                                }
                            }
                            currentDiscUrl = url
                            break
                        default:
                            print("Error! neither disc or bios file type selected!")
                            break
                        }
                    }
                }
        }
        .commands {
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
        }

        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
