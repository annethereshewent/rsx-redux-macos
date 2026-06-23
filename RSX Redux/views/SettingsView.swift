//
//  SettingsView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

enum ControllerMode: Codable {
    case auto
    case digital
    case analog
}

struct SettingsView: View {
    @EnvironmentObject private var emulatorCore: EmulatorCore
    @Binding var currentGame: Game?
    @Binding var user: GIDGoogleUser?
    @State private var selectedController: UInt8 = 0
    @State private var controllerMode: ControllerMode = .auto
    @State private var vibration = true
    @State private var showKeyboardBindings = false
    @State private var playAudio = true
    @State private var memoryCard: String = "memory_card.mcd"
    private let userDefaults = UserDefaults.standard

    var body: some View {
        if !showKeyboardBindings {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 24)

                    settingsSection("Controller") {
                        settingsRow("Selected Controller") {
                            Picker("", selection: $selectedController) {
                                Text("Port 1").tag(UInt8(0))
                                Text("Port 2").tag(UInt8(1))
                            }
                            .pickerStyle(.radioGroup)
                            .horizontalRadioGroupLayout()
                        }
                        Divider()
                        settingsRow("Controller Mode") {
                            Picker("", selection: $controllerMode) {
                                Text("Auto").tag(ControllerMode.auto)
                                Text("Digital").tag(ControllerMode.digital)
                                Text("Analog").tag(ControllerMode.analog)
                            }
                            .frame(width: 120)
                        }
                        Divider()
                        settingsRow("Vibration") {
                            Picker("", selection: $vibration) {
                                Text("On").tag(true)
                                Text("Off").tag(false)
                            }
                            .pickerStyle(.radioGroup)
                            .horizontalRadioGroupLayout()
                        }
                        Divider()
                        settingsRow("Keyboard Bindings") {
                            Button("Configure…") {
                                showKeyboardBindings = true
                            }
                        }
                    }

                    settingsSection("Audio") {
                        settingsRow("Playback") {
                            Picker("", selection: $playAudio) {
                                Text("On").tag(true)
                                Text("Off").tag(false)
                            }
                            .pickerStyle(.radioGroup)
                            .horizontalRadioGroupLayout()
                        }
                    }

                    settingsSection("System") {
                        settingsRow("Memory Card") {
                            Picker("", selection: $memoryCard) {
                                Text("Memory Card 1").tag("memory_card.mcd")
                                Text("Memory Card 2").tag("memory_card2.mcd")
                                Text("Memory Card 3").tag("memory_card3.mcd")
                                Text("Memory Card 4").tag("memory_card4.mcd")
                                Text("Memory Card 5").tag("memory_card5.mcd")
                            }
                            .frame(width: 160)
                            .disabled(currentGame != nil)
                        }
                    }

                    settingsSection("Cloud Saves") {
                        settingsRow("Google Account") {
                            if let user = user {
                                Button("Sign out of \(user.profile?.email ?? "user account")") {
                                    handleSignOut()
                                }
                            } else {
                                Button("Sign in") {
                                    handleSignInButton()
                                }
                            }
                        }
                    }
                }
                .padding(32)
            }
        } else {
            VStack {
                Text("Controller Settings")
                    .font(.largeTitle)
                    .bold()
                KeyboardBindingsView(showKeyboardBindings: $showKeyboardBindings)
                    .environmentObject(emulatorCore)
            }
        }
    }

    private func handleSignInButton() {
        guard let presenting = NSApplication.shared.keyWindow else {
            return
        }
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presenting)
        { signInResult, error in
            guard let result = signInResult	else {
                print(error!)
                return
            }

            print("sign in succeeded!")
            user = result.user
        }
    }

    private func handleSignOut() {
        guard let presenting = NSApplication.shared.keyWindow else {
            return
        }
        GIDSignIn.sharedInstance.signOut()
        user = nil
    }

    @ViewBuilder
    private func settingsSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.bottom, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.separator, lineWidth: 0.5)
            )
        }
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private func settingsRow<Content: View>(
        _ label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
