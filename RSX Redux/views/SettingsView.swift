//
//  SettingsView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var emulatorCore: EmulatorCore
    @State private var selectedController: UInt8 = 0
    @State private var digitalMode = true
    @State private var vibration = true
    @State private var showKeyboardBindings = false
    @State private var audio = true
    @State private var memoryCard: String = "memory_card.mcd"

    var body: some View {
        VStack {

            if !showKeyboardBindings {
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                Text("Controller")
                    .font(.title)
                    .bold()
                HStack {
                    Spacer()
                    Picker("Selected Controller", selection: $selectedController) {
                        Text("Port 1").tag(UInt8(0))
                        Text("Port 2").tag(UInt8(1))
                    }
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    Spacer()
                    Picker("Controller mode", selection: $digitalMode) {
                        Text("Digital mode").tag(true)
                        Text("Analog mode").tag(false)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    Spacer()
                    Picker("Vibration", selection: $vibration) {
                        Text("On").tag(true)
                        Text("Off").tag(false)
                    }
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    Spacer()
                    Button("Keyboard bindings") {
                        showKeyboardBindings = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                Text("Audio")
                    .font(.title)
                    .bold()
                HStack {
                    Spacer()
                    Picker("Audio", selection: $audio) {
                        Text("On").tag(true)
                        Text("Off").tag(false)
                    }
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text("System")
                    .font(.title)
                    .bold()
                HStack {
                    Spacer()
                    Picker("Current memory card", selection: $memoryCard) {
                        Text("Memory card 1").tag("memory_card.mcd")
                        Text("Memory card 2").tag("memory_card2.mcd")
                        Text("Memory card 3").tag("memory_card3.mcd")
                        Text("Memory card 4").tag("memory_card4.mcd")
                        Text("Memory card 5").tag("memory_card5.mcd")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            } else {
                Text("Controller Settings")
                    .font(.largeTitle)
                    .bold()
                KeyboardBindingsView()
            }
        }
        .onChange(of: selectedController) {
            emulatorCore.switchSelectedController(controllerId: selectedController)
        }
        .onChange(of: vibration) {
            emulatorCore.setVibration(vibration)
        }
        .onChange(of: digitalMode) {
            emulatorCore.setDigitalMode(digitalMode)
        }
        .onChange(of: audio) {
            emulatorCore.switchAudio(audio)
        }
    }
}
