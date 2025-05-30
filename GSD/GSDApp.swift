//
//  GSDApp.swift
//  GSD
//
//  Created by Asaf Navon on 5/15/25.
//

import SwiftUI
import SwiftData

@main
struct GSDApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView().preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
