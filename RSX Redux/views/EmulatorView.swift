//
//  EmulatorView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import AppKit

let KEY_W: UInt = 13
let KEY_S: UInt = 1
let KEY_A: UInt = 0
let KEY_D: UInt = 2

let KEY_I: UInt = 34
let KEY_L: UInt = 37
let KEY_J: UInt = 38
let KEY_K : UInt = 40

let KEY_U: UInt = 32
let KEY_O: UInt = 31

let KEY_7: UInt = 26
let KEY_9: UInt = 25

let KEY_TAB: UInt = 48
let KEY_ENTER: UInt = 36

let LEFT_SHIFT: UInt = 131330
let RIGHT_SHIFT: UInt = 131332

let FLAG_UP = 256

struct EmulatorView: NSViewRepresentable {
    @EnvironmentObject var core: EmulatorCore
    func makeNSView(context: Context) -> EmulatorNSView {
        let view = EmulatorNSView()
        view.wantsLayer = true
        view.layer = core.layer
        view.emulatorCore = core

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
    var emulatorCore: EmulatorCore? = nil
    private var lastFlag: UInt = 0

    private let keyDict: [UInt: PressedButton] = [
        KEY_W: .up,
        KEY_S: .down,
        KEY_A: .left,
        KEY_D: .right,

        KEY_I: .triangle,
        KEY_K: .cross,
        KEY_J: .square,
        KEY_L: .circle,

        KEY_ENTER: .start,
        KEY_TAB: .select,

        KEY_U: .l1,
        KEY_O: .r1,
        KEY_7: .l2,
        KEY_9: .r2,
    ]

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        guard let window else { return }

        window.setContentSize(NSSize(width: 1280, height: 960))
    }
    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        if let button = keyDict[UInt(event.keyCode)] {
            emulatorCore?.updateInput(button, true)
        }

    }

    override func keyUp(with event: NSEvent) {
        if let button = keyDict[UInt(event.keyCode)] {
            emulatorCore?.updateInput(button, false)
        }
    }

    override func flagsChanged(with event: NSEvent) {
        let flag = event.modifierFlags.rawValue

        if flag == LEFT_SHIFT {
            emulatorCore?.updateInput(PressedButton.leftStick, true)
        } else if flag == RIGHT_SHIFT {
            emulatorCore?.updateInput(PressedButton.rightStick, true)
        } else if flag == FLAG_UP && lastFlag == LEFT_SHIFT {
            emulatorCore?.updateInput(PressedButton.leftStick, false)
        } else if flag == FLAG_UP && lastFlag == RIGHT_SHIFT {
            emulatorCore?.updateInput(PressedButton.rightStick, false)
        }

        lastFlag = flag
    }
}
