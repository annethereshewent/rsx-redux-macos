//
//  ContentView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import SwiftData
import GameController

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var emulatorCore: EmulatorCore

    @Binding var currentDiscUrl: URL?
    @Binding var currentBiosUrl: URL?
    @State private var gameController: GameController?
    @State private var touchpadLatch = false

    private func addControllerEventListeners(_ controller: GCController?) {
        if let controller = controller?.extendedGamepad as? GCDualSenseGamepad {
            print("dual sense detected")
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
            print("toggling digital mode!")
            emulatorCore.toggleDigitalMode()
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                self.touchpadLatch = false
            }
        }
    }

    func updateInput(_ button: PressedButton, _ pressed: Bool) {
        emulatorCore.updateInput(button, pressed)
    }

    var body: some View {
        EmulatorView()
            .aspectRatio(4/3, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .onChange(of: currentDiscUrl) {
                if let url = currentDiscUrl {
                    gameController = GameController() { controller in
                        addControllerEventListeners(controller)
                    }
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
