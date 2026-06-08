//
//  GameController.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/3/26.
//

import Foundation
import GameController
import PSXMacEmulator
import CoreHaptics

enum PressedButton: UInt, Codable {
    case circle = 13
    case cross = 14
    case triangle = 12
    case square = 15
    case select = 0
    case start = 3
    case leftStick = 1
    case rightStick = 2
    case l1 = 10
    case r1 = 11
    case l2 = 8
    case r2 = 9
    case up = 4
    case down = 6
    case left = 7
    case right = 5
    case analog = 16
}

@Observable
class GameController {
    let eventListenerClosure: (GCController) -> Void
    private var engine: CHHapticEngine?
    private var smallEngine: CHHapticEngine?
    private var largeEngine: CHHapticEngine?

    var controller: GCController? = GCController()

    init(closure: @escaping (GCController) -> Void) {
        eventListenerClosure = closure
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleControllerDidConnect),
            name: NSNotification.Name.GCControllerDidConnect, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleControllerDidDisconnect),
            name: NSNotification.Name.GCControllerDidDisconnect,
            object: nil
        )


        if let controller = GCController.controllers().first {
            self.controller = controller
            self.controller?.physicalInputProfile.buttons[GCInputButtonHome]?.preferredSystemGestureState = GCControllerElement.SystemGestureState.disabled
            prepareHaptics()

            eventListenerClosure(controller)
        }
    }

    private func prepareHaptics() {
        if let controller = controller, let haptics = controller.haptics {
            do {
                if haptics.supportedLocalities.contains(.leftHandle) && haptics.supportedLocalities.contains(.rightHandle) {
                    smallEngine = haptics.createEngine(withLocality: .leftHandle)
                    largeEngine = haptics.createEngine(withLocality: .rightHandle)

                    try smallEngine?.start()
                    try largeEngine?.start()
                } else {
                    engine = haptics.createEngine(withLocality: .default)
                    try engine?.start()
                }


            } catch {
                print(error)
            }
        }
    }

    func handleRumble(smallEngineIntensity: Float, largeEngineIntensity: Float) {
        if let smallEngine = smallEngine {
            rumble(smallEngine, intensity: smallEngineIntensity, duration: 0.2)
        }
        if let largeEngine = largeEngine {
            rumble(largeEngine, intensity: largeEngineIntensity, duration: 0.2)
        }

        if largeEngine == nil && smallEngine == nil {
            if let engine = engine {
                rumble(engine, intensity: max(smallEngineIntensity, largeEngineIntensity), duration: 0.2)
            }
        }
    }

    private func rumble(_ engine: CHHapticEngine, intensity: Float, duration: TimeInterval) {
        let intensity = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: intensity
        )

        let sharpness = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: 0.4
        )

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic:", error)
        }
    }

    @objc private func handleControllerDidDisconnect(_ notification: Notification) {
        self.controller = nil
    }

    @objc private func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }

        gameController.physicalInputProfile.buttons[GCInputButtonHome]?.preferredSystemGestureState = GCControllerElement.SystemGestureState.disabled

        self.controller = gameController
        prepareHaptics()

        eventListenerClosure(gameController)
    }
}
