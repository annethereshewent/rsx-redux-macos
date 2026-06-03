//
//  RSX_ReduxApp.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import SwiftUI
import SwiftData

@main
struct RSX_ReduxApp: App {
    @StateObject private var emulatorCore = EmulatorCore()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(emulatorCore)
                .onAppear { emulatorCore.initialize() }
        }
        .modelContainer(sharedModelContainer)

        Settings {
            SettingsView()
        }
    }
}
