//
//  SettingsView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI

enum ControllerMode: Codable {
    case auto
    case digital
    case analog
}

struct SettingsView: View {
    @EnvironmentObject private var emulatorCore: EmulatorCore
    @Binding var currentGame: Game?
    @State private var selectedController: UInt8 = 0
    @State private var controllerMode: ControllerMode = .auto
    @State private var vibration = true
    @State private var showKeyboardBindings = false
    @State private var playAudio = true
    @State private var memoryCard: String = "memory_card.mcd"
    private let userDefaults = UserDefaults.standard

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
                    Picker("Controller mode", selection: $controllerMode) {
                        Text("Auto").tag(ControllerMode.auto)
                        Text("Digital mode").tag(ControllerMode.digital)
                        Text("Analog mode").tag(ControllerMode.analog)
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
                    Picker("Audio", selection: $playAudio) {
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
                    .disabled(currentGame != nil)
                }
                Spacer()
            } else {
                Text("Controller Settings")
                    .font(.largeTitle)
                    .bold()
                KeyboardBindingsView(showKeyboardBindings: $showKeyboardBindings)
            }
        }
        .onChange(of: selectedController) {
            userDefaults.set(selectedController, forKey: "selectedController")
            emulatorCore.switchSelectedController(controllerId: selectedController)
        }
        .onChange(of: vibration) {
            userDefaults.set(vibration, forKey: "vibration")
            emulatorCore.setVibration(vibration)
        }
        .onChange(of: controllerMode) {
            do {
                let encoded = try JSONEncoder().encode(controllerMode)
                userDefaults.set(encoded, forKey: "controllerMode")
            } catch {
                print(error)
            }
            emulatorCore.setControllerMode(controllerMode)
        }
        .onChange(of: playAudio) {
            userDefaults.set(playAudio, forKey: "playAudio")
            emulatorCore.switchAudio(playAudio)
        }
        .onChange(of: memoryCard) {
            userDefaults.set(memoryCard, forKey: "memoryCard")
            emulatorCore.setMemoryCard(memoryCard)
        }
        .onAppear {
            if userDefaults.object(forKey: "selectedController") != nil {
                self.selectedController = UInt8(userDefaults.integer(forKey: "selectedController"))
            }

            if userDefaults.object(forKey: "vibration") != nil {
                vibration = userDefaults.bool(forKey: "vibration")
            }
            if let memoryCard = userDefaults.string(forKey: "memoryCard") {
                self.memoryCard = memoryCard
            }
            if userDefaults.object(forKey: "playAudio") != nil {
                playAudio = userDefaults.bool(forKey: "playAudio")
            }
            if let controllerModeData = userDefaults.object(forKey: "controllerMode") {
                do {
                    let controllerMode = try JSONDecoder().decode(ControllerMode.self, from: controllerModeData as! Data)
                    self.controllerMode = controllerMode
                } catch {
                    print(error)
                }
            }
        }
    }
}
