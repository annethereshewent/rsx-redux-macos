//
//  KeyboardBindingsView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/6/26.
//

import SwiftUI

struct KeyboardBindingsView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 32) {
            Spacer()
            Spacer()
            VStack() {
                MappingGroup(title: "D-Pad") {
                    VStack {
                        HStack {
                            Spacer()
                                .frame(width: 5)
                                .fixedSize()
                            MappingButton(title: "Up", binding: "W")
                            Spacer()
                                .frame(width: 5)
                                .fixedSize()
                        }
                        HStack {
                            MappingButton(title: "Left", binding: "A")
//                            Spacer()
//                                .frame(width: 5)
//                                .fixedSize()
                            MappingButton(title: "Right", binding: "D")
                        }
                        HStack {
                            Spacer()
                                .frame(width: 5)
                                .fixedSize()
                            MappingButton(title: "Down", binding: "S")
                            Spacer()
                                .frame(width: 5)
                                .fixedSize()
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
                            Spacer()
                                .frame(width: 10)
                                .fixedSize()
                            MappingButton(title: "Triangle", binding: "I")
                            Spacer()
                                .frame(width: 10)
                                .fixedSize()
                        }
                        HStack {
                            MappingButton(title: "Square", binding: "J")
                            Spacer()
                                .frame(width: 10)
                                .fixedSize()
                            MappingButton(title: "Circle", binding: "L")
                        }
                        HStack {
                            Spacer()
                                .frame(width: 10)
                                .fixedSize()
                            MappingButton(title: "Cross", binding: "K")
                            Spacer()
                                .frame(width: 10)
                                .fixedSize()
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
}

#Preview {
    KeyboardBindingsView()
}
