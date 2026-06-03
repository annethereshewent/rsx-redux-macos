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
    private(set) var layer: CAMetalLayer?
    private var initialized = false
    private var emulator: PsxMacEmulator?

    func initialize() {
        guard !initialized else { return }
        initialized = true

        let metalLayer = CAMetalLayer()
        metalLayer.device = MTLCreateSystemDefaultDevice()
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true

        self.layer = metalLayer

        let ptr = Unmanaged.passUnretained(metalLayer).toOpaque()
        emulator = PsxMacEmulator(ptr)
    }

    func shutdown() {
        guard initialized else { return }
        layer = nil
        initialized = false
    }
}
