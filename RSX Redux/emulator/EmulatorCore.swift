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

    func initialize() {
        guard !initialized else { return }
        initialized = true

        let metalLayer = CAMetalLayer()
        metalLayer.device = MTLCreateSystemDefaultDevice()
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true

        let ptr = Unmanaged.passUnretained(metalLayer).toOpaque()

        emulator = PsxMacEmulator(ptr)

        self.layer = metalLayer
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

                guard !isRunning else { return }

                isRunning = true
                emuQueue.async { [weak self] in
                    guard let self else { return }
                    while self.isRunning {
                        emulator.stepFrame()
                    }
                }
            }
        }
    }

    func stepFrame() {
        emulator!.stepFrame()
    }

    func loadBios(biosUrl: URL) {
        if let emulator = emulator {
            let biosPath = biosUrl.path

            emulator.loadBios(biosPath)
            biosLoaded = true
        }
    }
}
