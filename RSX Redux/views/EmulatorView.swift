//
//  EmulatorView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import AppKit

struct EmulatorView: NSViewRepresentable {
    @EnvironmentObject var core: EmulatorCore
    func makeNSView(context: Context) -> EmulatorNSView {
        let view = EmulatorNSView(layer: core.layer)
        view.wantsLayer = true
        view.emulatorCore = core

        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }

        return view
    }

    func updateNSView(_ nsView: EmulatorNSView, context: Context) {
        // NOP
    }
}

class EmulatorNSView: NSView {
    var emulatorCore: EmulatorCore? = nil
    private var lastKey: UInt16 = 0

    let metalLayer: CAMetalLayer

    init(layer: CAMetalLayer) {
        self.metalLayer = layer
        super.init(frame: .zero)
        self.wantsLayer = true
        self.layer = layer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        guard let window else { return }

        window.setContentSize(NSSize(width: 1280, height: 960))
    }
    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        emulatorCore?.onKeyInput(event.keyCode, true)
    }

    override func keyUp(with event: NSEvent) {
        emulatorCore?.onKeyInput(event.keyCode, false)
    }

    override func flagsChanged(with event: NSEvent) {
        let flag = event.modifierFlags.rawValue
        let keyCode = event.keyCode

        if flag == 256 {
            emulatorCore?.onKeyInput(lastKey, false)
        } else {
            emulatorCore?.onKeyInput(keyCode, true)
        }

        lastKey = keyCode
    }
}
