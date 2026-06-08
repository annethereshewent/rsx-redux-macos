//
//  ContentView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import SwiftData
import GameController
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var emulatorCore: EmulatorCore

    @Binding var currentDiscUrl: URL?
    @Binding var currentBiosUrl: URL?
    @Binding var initialize: Bool
    @Binding var currentGame: Game?
    @Binding var showDialog: Bool
    @Binding var fileType: FileType?
    @State private var gameController: GameController?
    @State private var touchpadLatch = false

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Query private var games: [Game]
    @Environment(\.modelContext) private var context

    let binType = UTType(filenameExtension: "bin", conformingTo: .data)
    let exeType = UTType(filenameExtension: "exe", conformingTo: .data)

    private func addControllerEventListeners(_ controller: GCController?) {
        if let controller = controller?.extendedGamepad as? GCDualSenseGamepad {
            handleExtendedGamepadInput(controller as GCExtendedGamepad)
            handleDsenseGamepadInput(controller)
        } else if let controller = controller?.extendedGamepad as? GCDualShockGamepad {
            handleExtendedGamepadInput(controller as GCExtendedGamepad)
            handleDshockGamepadInput(controller)
        } else if let controller = controller?.extendedGamepad {
            handleExtendedGamepadInput(controller)
        }
    }

    private func handleDsenseGamepadInput(_ controller: GCDualSenseGamepad) {
        controller.touchpadButton.pressedChangedHandler = { (button, value, pressed) in
            toggleDigitalMode(pressed)
        }
    }

    private func handleDshockGamepadInput(_ controller: GCDualShockGamepad) {
        controller.touchpadButton.pressedChangedHandler = { (button, value, pressed) in
            toggleDigitalMode(pressed)
        }
    }

    private func handleExtendedGamepadInput(_ controller: GCExtendedGamepad) {
        controller.buttonB.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.circle, pressed)
        }
        controller.buttonA.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.cross, pressed)
        }
        controller.buttonX.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.square, pressed)
        }
        controller.buttonY.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.triangle, pressed)
        }
        controller.dpad.up.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.up, pressed)
        }
        controller.dpad.down.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.down, pressed)
        }
        controller.dpad.left.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.left, pressed)
        }
        controller.dpad.right.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.right, pressed)
        }
        controller.buttonOptions?.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.select, pressed)
        }
        controller.buttonMenu.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.start, pressed)
        }
        controller.rightThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.rightStick, pressed)
        }
        controller.leftThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.leftStick, pressed)
        }
        controller.rightShoulder.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.r1, pressed)
        }
        controller.leftShoulder.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.l1, pressed)
        }
        controller.rightTrigger.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.r2, pressed)
        }
        controller.leftTrigger.pressedChangedHandler = { (button, value, pressed) in
            updateInput(.l2, pressed)
        }
        controller.leftThumbstick.valueChangedHandler = { dpad, xValue, yValue in
            let xValue = if xValue < 0.0 {
                (Int16(-xValue * -32768) >> 8)
            } else {
                (Int16(xValue * 32767) >> 8)
            }

            let yValue = if yValue < 0.0 {
                (Int16(-yValue * 32767) >> 8)
            } else {
                (Int16(yValue * -32768) >> 8)
            }

            let normalizedX = UInt8(xValue + 128)
            let normalizedY = UInt8(yValue + 128)

            emulatorCore.setLeftThumbstick(normalizedX, normalizedY)

        }
        controller.rightThumbstick.valueChangedHandler = { dpad, xValue, yValue in
            let xValue = if xValue < 0.0 {
                (Int16(-xValue * -32768) >> 8)
            } else {
                (Int16(xValue * 32767) >> 8)
            }

            let yValue = if yValue < 0.0 {
                (Int16(-yValue * 32767) >> 8)
            } else {
                (Int16(yValue * -32768) >> 8)
            }

            let normalizedX = UInt8(xValue + 128)
            let normalizedY = UInt8(yValue + 128)
            
            emulatorCore.setRightThumbstick(normalizedX, normalizedY)
        }
    }

    func toggleDigitalMode(_ pressed: Bool) {
        if !touchpadLatch && pressed {
            touchpadLatch = true
        } else if touchpadLatch && !pressed {
            emulatorCore.toggleDigitalMode()
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                self.touchpadLatch = false
            }
        }
    }

    func updateInput(_ button: PressedButton, _ pressed: Bool) {
        emulatorCore.updateInput(button, pressed)
    }

    func storeBios(location: URL, data: Data) -> URL? {
        let appPath = location.appendingPathComponent("RSX Redux", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: appPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }

        if let url = URL(string: "bios.bin", relativeTo: appPath) {
            try! data.write(to: url)

            return url
        }

        return nil
    }

    var body: some View {
        EmulatorView()
            .aspectRatio(4/3, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .onChange(of: currentBiosUrl) {
                if let url = currentBiosUrl {
                    emulatorCore.loadBios(biosUrl: url)
                }
            }
            .onAppear() {
                emulatorCore.gameController = GameController() { controller in
                    addControllerEventListeners(controller)
                }
            }
            .fileImporter(isPresented: $showDialog, allowedContentTypes: [binType!, exeType!] ) { result in
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
                        let gameName = url.deletingPathExtension().lastPathComponent

                        if let index = games.firstIndex(where: { $0.gameName == gameName }) {
                            currentGame = games[index]
                        } else {
                            do {
                                guard url.startAccessingSecurityScopedResource() else { return }

                                let bookmark = try url.bookmarkData(
                                    options: [.withSecurityScope],
                                    includingResourceValuesForKeys: nil,
                                    relativeTo: nil
                                )

                                currentGame = Game(
                                    gameName: gameName,
                                    bookmark: bookmark,
                                    saveStates: [],
                                    lastPlayed: Date()
                                )

                                context.insert(currentGame!)
                            } catch {
                                print(error)
                            }
                        }
                        currentDiscUrl = url

                        if initialize {
                            if url.pathExtension == "exe" {
                                emulatorCore.startExe(exeUrl: url)
                            } else {
                                if emulatorCore.isRunning {
                                    emulatorCore.stopEmulatorThen {
                                        if let biosUrl = currentBiosUrl {
                                            emulatorCore.initialize()
                                            emulatorCore.loadBios(biosUrl: biosUrl)
                                            emulatorCore.startEmulator(gameUrl: url)
                                        }
                                    }
                                } else {
                                    if let biosUrl = currentBiosUrl {
                                        emulatorCore.initialize()
                                        emulatorCore.loadBios(biosUrl: biosUrl)
                                        emulatorCore.startEmulator(gameUrl: url)
                                    }
                                }
                            }
                        } else {
                            emulatorCore.mainLoop()
                        }
                        break
                    default: break
                    }
                }
            }
    }
}
