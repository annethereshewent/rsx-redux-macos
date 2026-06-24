//
//  SettingsView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn
import UniformTypeIdentifiers

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
    @State private var memoryCard = "memory_card1.mcd"
    @State private var cloudCard = "memory_card1.mcd"
    @State private var cardLastUpdated = ""
    @State private var cardFound = false
    @State private var showFileDialog = false
    @State private var fileUpdateMessage: String? = nil
    @State private var showConfirmDialog = false
    private let userDefaults = UserDefaults.standard
    private let mcdType = UTType(filenameExtension: "mcd", conformingTo: .data)

    var body: some View {
        if !showKeyboardBindings {
            ZStack {
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
                            settingsRow("Selected Memory Card") {
                                Picker("", selection: $memoryCard) {
                                    Text("Memory Card 1").tag("memory_card1.mcd")
                                    Text("Memory Card 2").tag("memory_card2.mcd")
                                    Text("Memory Card 3").tag("memory_card3.mcd")
                                    Text("Memory Card 4").tag("memory_card4.mcd")
                                    Text("Memory Card 5").tag("memory_card5.mcd")
                                }
                                .frame(width: 160)
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
                            if let _ = user {
                                Divider()
                                settingsRow("Manage memory card")  {
                                    Picker("", selection: $cloudCard) {
                                        Text("Memory Card 1").tag("memory_card1.mcd")
                                        Text("Memory Card 2").tag("memory_card2.mcd")
                                        Text("Memory Card 3").tag("memory_card3.mcd")
                                        Text("Memory Card 4").tag("memory_card4.mcd")
                                        Text("Memory Card 5").tag("memory_card5.mcd")
                                    }
                                }
                                if cardFound {
                                    settingsRow("Cloud: \(cardLastUpdated)") {
                                        Button() {
                                            showFileDialog = true
                                        } label: {
                                            Image(systemName: "icloud.and.arrow.up")
                                                .foregroundColor(.accentColor)
                                        }
                                        .help("Upload to cloud")
                                        Button() {
                                            
                                        } label: {
                                            Image(systemName: "icloud.and.arrow.down")
                                                .foregroundColor(.accentColor)
                                        }
                                        .help("Download from cloud")
                                        Button() {
                                            showConfirmDialog = true
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.accentColor)
                                        }
                                        .help("Delete from cloud")
                                    }
                                    .confirmationDialog("Delete cloud save?", isPresented: $showConfirmDialog) {
                                        Button("Delete") {
                                            if let cloudService = emulatorCore.cloudService {
                                                Task {
                                                    let success = await cloudService.deleteCard(cloudCard)
                                                    if success {
                                                        fileUpdateMessage = "Deleted card successfully"
                                                        updateCardLastUpdated()
                                                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                                            fileUpdateMessage = nil
                                                        }
                                                    }
                                                }
                                            }
                                            showConfirmDialog = false
                                        }
                                    } message: {
                                        Text("This will permanently delete your card from the cloud. Are you sure you want to continue?")
                                    }
                                }
                            }
                        }
                        .onAppear {
                            updateCardLastUpdated()
                        }
                        .onChange(of: cloudCard) {
                            updateCardLastUpdated()
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
                    .fileImporter(isPresented: $showFileDialog, allowedContentTypes: [mcdType!]) { result in
                        fileUpdateMessage = nil
                        if let url = try? result.get() {
                            if url.startAccessingSecurityScopedResource() {
                                defer {
                                    url.stopAccessingSecurityScopedResource()
                                }
                                if let cloudService = emulatorCore.cloudService {
                                    if let data = try? Data(contentsOf: url) {
                                        Task {
                                            await cloudService.uploadCard(cloudCard, data)
                                            fileUpdateMessage = "Successfully uploaded card"
                                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                                fileUpdateMessage = nil
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        showFileDialog = false

                    }
                    .padding(32)
                }
                if let fileUpdateMessage = fileUpdateMessage {
                    Text(fileUpdateMessage)
                        .font(.system(size: 24))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 24)
                }
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

    func updateCardLastUpdated() {
        cardFound = false
        if let cloudService = emulatorCore.cloudService {
            Task {
                if let info = await cloudService.getCardInfo(cloudCard) {
                    if info.files.count > 0, let date = info.files[0].modifiedTime {
                        let dateFormatter = ISO8601DateFormatter()
                        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        let date = dateFormatter.date(from: date)

                        cardLastUpdated = date?.formatted() ?? ""
                        cardFound = true
                    }
                }
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

            user = result.user
        }
    }

    private func handleSignOut() {
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
