//
//  KeyCaptureView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/7/26.
//


import AppKit
import SwiftUI

class KeyCaptureView: NSView {
    var onKeyDown: ((NSEvent) -> Void)?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func keyDown(with event: NSEvent) {
        onKeyDown?(event)
    }
}

struct KeyCaptureRepresentable: NSViewRepresentable {
    let onKeyDown: (NSEvent) -> Void

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.onKeyDown = onKeyDown

        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }

        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {}
}
