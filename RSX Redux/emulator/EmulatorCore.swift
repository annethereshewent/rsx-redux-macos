//
//  EmulatorCore.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//
import Foundation
import MetalKit
import PSXMacEmulator
import Combine

class EmulatorCore: ObservableObject {
    @Published private(set) var layer: CAMetalLayer?
    private var initialized = false
    private var emulator: PsxMacEmulator?
    @Published var isRunning = false
    @Published var biosLoaded = false
    private let emuQueue = DispatchQueue(label: "rsx-redux.emu", qos: .userInteractive)
    private let audioManager = AudioManager()

    func initialize() {
        if !initialized {
            initialized = true

            let metalLayer = CAMetalLayer()
            metalLayer.device = MTLCreateSystemDefaultDevice()
            metalLayer.pixelFormat = .bgra8Unorm
            metalLayer.framebufferOnly = true

            self.layer = metalLayer
        }

        let ptr = Unmanaged.passUnretained(layer!).toOpaque()

        emulator = PsxMacEmulator(ptr)


    }

    func shutdown() {
        guard initialized else { return }
        layer = nil
        initialized = false
    }

    func startEmulator(gameUrl: URL) {
        if let emulator = emulator {
            if gameUrl.startAccessingSecurityScopedResource() {
                defer {
                    gameUrl.stopAccessingSecurityScopedResource()
                }

                let gamePath = gameUrl.path
                emulator.loadRom(gamePath)

                audioManager.startAudio()

                isRunning = true
                emuQueue.async { [weak self] in
                    guard let self else { return }
                    while self.isRunning {
                        emulator.stepFrame()

                        let samples = emulator.drainSamples()

                        self.audioManager.updateBuffer(samples: samples)
                    }
                }
            }
        }
    }

    func stepFrame() {
        emulator?.stepFrame()
    }

    func loadBios(biosUrl: URL) {
        let biosPath = biosUrl.path

        emulator?.loadBios(biosPath)
        biosLoaded = true
    }

    func toggleDigitalMode() {
        emulator?.toggleDigitalMode()
    }

    func updateInput(_ button: PressedButton, _ pressed: Bool) {
        emulator?.updateInput(button.rawValue, pressed)
    }

    func setLeftThumbstick(_ normalizedX: UInt8, _ normalizedY: UInt8) {
        emulator?.setLeftThumbstick(normalizedX, normalizedY)
    }

    func setRightThumbstick(_ normalizedX: UInt8, _ normalizedY: UInt8) {
        emulator?.setRightThumbstick(normalizedX, normalizedY)
    }
}
