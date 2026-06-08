//
//  KeyboardBindingsView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/6/26.
//

import SwiftUI

struct KeyBinding: Codable {
    let keyCode: UInt16
    let display: String
}

let KEY_W: UInt16 = 13
let KEY_S: UInt16 = 1
let KEY_A: UInt16 = 0
let KEY_D: UInt16 = 2

let KEY_I: UInt16 = 34
let KEY_L: UInt16 = 37
let KEY_J: UInt16 = 38
let KEY_K : UInt16 = 40

let KEY_U: UInt16 = 32
let KEY_O: UInt16 = 31

let KEY_7: UInt16 = 26
let KEY_9: UInt16 = 25

let KEY_TAB: UInt16 = 48
let KEY_ENTER: UInt16 = 36

let KEY_E: UInt16 = 14

let LEFT_SHIFT: UInt16 = 56
let RIGHT_SHIFT: UInt16 = 60
let CTRL: UInt16 = 59
let LEFT_ALT: UInt16 = 58
let RIGHT_ALT: UInt16 = 61
let CAPS_LOCK: UInt16 = 57

let FLAG_UP: UInt16 = 256

let KEY_F4: UInt16 = 118
let KEY_F5: UInt16 = 96
let KEY_F7: UInt16 = 98

struct KeyboardBindingsView: View {
    @State private var currentButton: PressedButton?
    @EnvironmentObject var emulatorCore: EmulatorCore
    private let userDefaults = UserDefaults.standard

    private func getKeyName(_ event: NSEvent) -> String? {
        switch event.keyCode {
        case 126: return "Up"
        case 123: return "Left"
        case 125: return "Down"
        case 124: return "Right"
        default: break
        }

        if let key = event.characters {
            switch key {
            case "\n": return "Enter"
            case "\r": return "Enter"
            case "\t": return "Tab"
            default: break
            }
            return key.uppercased()
        }

        return nil
    }

    private func getFlagName(_ event: NSEvent) -> String? {
        switch (event.keyCode) {
        case LEFT_SHIFT: return "LeftShift"
        case RIGHT_SHIFT: return " RightShift"
        case CTRL: return "Ctrl"
        case LEFT_ALT: return "LeftAlt"
        case RIGHT_ALT: return "RightAlt"
        case CAPS_LOCK: return "Caps lock"
        default: return nil
        }
    }
    @Binding var showKeyboardBindings: Bool
    @State private var keyDict: [PressedButton:KeyBinding] = [
        .up: KeyBinding(keyCode: KEY_W, display: "W"),
        .down: KeyBinding(keyCode: KEY_S, display: "S"),
        .left: KeyBinding(keyCode: KEY_A, display: "A"),
        .right: KeyBinding(keyCode: KEY_D, display: "D"),
        .start: KeyBinding(keyCode: KEY_ENTER, display: "Enter"),
        .select: KeyBinding(keyCode: KEY_TAB, display: "Tab"),
        .analog: KeyBinding(keyCode: KEY_E, display: "E"),
        .cross: KeyBinding(keyCode: KEY_K, display: "K"),
        .circle: KeyBinding(keyCode: KEY_L, display: "L"),
        .square: KeyBinding(keyCode: KEY_J, display: "J"),
        .triangle: KeyBinding(keyCode: KEY_I, display: "I"),
        .l1: KeyBinding(keyCode: KEY_U, display: "U"),
        .r1: KeyBinding(keyCode: KEY_O, display: "O"),
        .l2: KeyBinding(keyCode: KEY_7, display: "7"),
        .r2: KeyBinding(keyCode: KEY_9, display: "9"),
        .leftStick: KeyBinding(keyCode: LEFT_SHIFT, display: "LeftShift"),
        .rightStick: KeyBinding(keyCode: RIGHT_SHIFT, display: "RightShift")
    ]

    func updateKeyDict(_ event: NSEvent, _ display: String) {
        if let currentButton = currentButton {
            for (key, value) in keyDict {
                if value.keyCode == event.keyCode {
                    if let keyBinding = keyDict[currentButton] {
                        keyDict[key] = keyBinding
                    }
                }
            }

            keyDict[currentButton] = KeyBinding(keyCode: event.keyCode, display: display)
            self.currentButton = nil
        }
    }

    var body: some View {
        KeyCaptureRepresentable(onKeyDown: { event in
            if let display = getKeyName(event) {
                updateKeyDict(event, display)
            }
        }, onFlagsChanged: { event in
            if let display = getFlagName(event) {
                updateKeyDict(event, display)
            }
        })
        .frame(width: 0, height: 0)
        VStack {
            HStack(alignment: .center, spacing: 32) {
                Spacer()
                Spacer()
                VStack() {
                    MappingGroup(title: "D-Pad") {
                        VStack {
                            HStack {
                                MappingButton(
                                    title: "Up",
                                    binding: keyDict[.up]?.display ?? "W",
                                    button: .up,
                                    isListening: currentButton == .up
                                ) { button in
                                    currentButton = button
                                }
                            }
                            HStack {
                                MappingButton(
                                    title: "Left",
                                    binding: keyDict[.left]?.display ?? "A",
                                    button: .left,
                                    isListening: currentButton == .left
                                ) { button in
                                    currentButton = button
                                }
                                MappingButton(
                                    title: "Right",
                                    binding: keyDict[.right]?.display ?? "D",
                                    button: .right,
                                    isListening: currentButton == .right
                                ) { button in
                                    currentButton = button
                                }
                            }
                            HStack {
                                MappingButton(
                                    title: "Down",
                                    binding: keyDict[.down]?.display ?? "S",
                                    button: .down,
                                    isListening: currentButton == .down
                                ) { button in
                                    currentButton = button
                                }
                            }
                        }
                    }
                    .fixedSize()
                }
                .frame(width: 260, height: 260)
                .padding(.leading, 100)
                VStack() {
                    HStack {
                        MappingButton(
                            title: "L2",
                            binding: keyDict[.l2]?.display ??  "7",
                            button: .l2,
                            isListening: currentButton == .l2
                        ) { button in
                            currentButton = button
                        }
                        Spacer()
                        MappingButton(
                            title: "R2",
                            binding: keyDict[.r2]?.display ??  "9",
                            button: .r2,
                            isListening: currentButton == .r2
                        ) { button in
                            currentButton = button
                        }
                    }
                    .padding(.top, 40)
                    HStack {
                        MappingButton(
                            title: "L1",
                            binding: keyDict[.l1]?.display ??  "U",
                            button: .l1,
                            isListening: currentButton == .l1
                        ) { button in
                            currentButton = button
                        }
                        Spacer()
                        MappingButton(
                            title: "R1",
                            binding: keyDict[.r1]?.display ??  "O",
                            button: .r1,
                            isListening: currentButton == .r1
                        ) { button in
                            currentButton = button
                        }
                    }

                    HStack {
                        MappingButton(
                            title: "Select",
                            binding: keyDict[.select]?.display ??  "Tab",
                            button: .select,
                            isListening: currentButton == .select
                        ) { button in
                            currentButton = button
                        }
                        MappingButton(
                            title: "Start",
                            binding: keyDict[.start]?.display ??  "Enter",
                            button: .start,
                            isListening: currentButton == .start
                        ) { button in
                            currentButton = button
                        }
                    }

                    Image("ps1-controller")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 420)

                    HStack {
                        MappingButton(
                            title: "L3",
                            binding: keyDict[.leftStick]?.display ??  "LeftShift",
                            button: .leftStick,
                            isListening: currentButton == .leftStick
                        ) { button in
                            currentButton = button
                        }
                        MappingButton(
                            title: "Analog",
                            binding: keyDict[.analog]?.display ??  "E",
                            button: .analog,
                            isListening: currentButton == .analog
                        ) { button in
                            currentButton = button
                        }
                        MappingButton(
                            title: "R3",
                            binding: keyDict[.rightStick]?.display ??  "RightShift",
                            button: .rightStick,
                            isListening: currentButton == .rightStick
                        ) { button in
                            currentButton = button
                        }
                    }
                }
                VStack() {
                    MappingGroup(title: "Face Buttons") {
                        VStack {
                            HStack {
                                MappingButton(
                                    title: "Triangle",
                                    binding: keyDict[.triangle]?.display ??  "I",
                                    button: .triangle,
                                    isListening: currentButton == .triangle
                                ) { button in
                                    currentButton = button
                                }
                            }
                            HStack {
                                MappingButton(
                                    title: "Square",
                                    binding: keyDict[.square]?.display ??  "J",
                                    button: .square,
                                    isListening: currentButton == .square
                                ) { button in
                                    currentButton = button
                                }
                                MappingButton(
                                    title: "Circle",
                                    binding: keyDict[.circle]?.display ??  "L",
                                    button: .circle,
                                    isListening: currentButton == .circle
                                ) { button in
                                    currentButton = button
                                }
                            }
                            HStack {
                                MappingButton(
                                    title: "Cross",
                                    binding: keyDict[.cross]?.display ??  "K",
                                    button: .cross,
                                    isListening: currentButton == .cross
                                ) { button in
                                    currentButton = button
                                }
                            }
                        }
                    }
                }
                .frame(width: 260, height: 260)
                .padding(.trailing, 100)
                Spacer()
                Spacer()
            }
        }
        HStack {
            Button("Save changes") {
                do {
                    let encoded = try JSONEncoder().encode(keyDict)
                    userDefaults.set(encoded, forKey: "keyDict")
                } catch {
                    print(error)
                }
                emulatorCore.updateBindings(keyDict)
                showKeyboardBindings = false
            }
            .foregroundColor(.green)
            Button("Discard changes") {
                showKeyboardBindings = false
            }
            .foregroundColor(.red)
        }
        .padding(.top, 40)
        .onAppear {
            if let data = userDefaults.object(forKey: "keyDict") {
                do {
                    let decoded = try JSONDecoder().decode([PressedButton:KeyBinding].self, from: data as! Data)
                    keyDict = decoded
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var showKeyboardBindings: Bool = true
    KeyboardBindingsView(showKeyboardBindings: $showKeyboardBindings)
}
