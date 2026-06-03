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
        let view = EmulatorNSView()
        view.wantsLayer = true
        view.layer = core.layer

        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }

        return view
    }

    func updateNSView(_ nsView: EmulatorNSView, context: Context) {
        // if SwiftUI recreated the view, reattach the layer
        if nsView.layer !== core.layer {
            nsView.layer = core.layer
        }
    }
}

class EmulatorNSView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        guard let window else { return }

        window.setContentSize(NSSize(width: 1280, height: 960))
    }
    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        // forward to Rust
    }

    override func keyUp(with event: NSEvent) {
        // forward to Rust
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
}
