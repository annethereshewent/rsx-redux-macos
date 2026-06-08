//
//  KeyboardBindingsView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/6/26.
//

import SwiftUI

struct KeyboardBindingsView: View {
    @Binding var showKeyboardBindings: Bool
    @State private var keyDict: [String:Int] = [:]
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 32) {
                Spacer()
                Spacer()
                VStack() {
                    MappingGroup(title: "D-Pad") {
                        VStack {
                            HStack {
                                MappingButton(title: "Up", binding: "W")
                            }
                            HStack {
                                MappingButton(title: "Left", binding: "A")
                                MappingButton(title: "Right", binding: "D")
                            }
                            HStack {
                                MappingButton(title: "Down", binding: "S")
                            }
                        }
                    }
                    .fixedSize()
                }
                .frame(width: 260, height: 260)
                .padding(.leading, 100)
                VStack() {
                    HStack {
                        MappingButton(title: "L2", binding: "7")
                        Spacer()
                        MappingButton(title: "R2", binding: "9")
                    }
                    .padding(.top, 40)
                    HStack {
                        MappingButton(title: "L1", binding: "U")
                        Spacer()
                        MappingButton(title: "R1", binding: "O")
                    }

                    HStack {
                        MappingButton(title: "Select", binding: "Tab")
                        MappingButton(title: "Start", binding: "Enter")
                    }

                    Image("ps1-controller")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 420)

                    HStack {
                        MappingButton(title: "L3", binding: "LeftShift")
                        MappingButton(title: "Analog", binding: "E")
                        MappingButton(title: "R3", binding: "RightShift")
                    }
                }
                VStack() {
                    MappingGroup(title: "Face Buttons") {
                        VStack {
                            HStack {
                                MappingButton(title: "Triangle", binding: "I")
                            }
                            HStack {
                                MappingButton(title: "Square", binding: "J")
                                MappingButton(title: "Circle", binding: "L")
                            }
                            HStack {
                                MappingButton(title: "Cross", binding: "K")
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
                showKeyboardBindings = false
            }
            .foregroundColor(.green)
            Button("Discard changes") {
                showKeyboardBindings = false
            }
            .foregroundColor(.red)
        }
        .padding(.top, 40)
    }
}

#Preview {
    @Previewable @State var showKeyboardBindings: Bool = true
    KeyboardBindingsView(showKeyboardBindings: $showKeyboardBindings)
}
