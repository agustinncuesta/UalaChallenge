//
//  UalaChallengeApp.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import SwiftUI
import SwiftData

@main
struct UalaChallengeApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CityLocalModel.self
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
        }
        .modelContainer(sharedModelContainer)
    }
}
