//
//  DripApp.swift
//  Drip
//
//  Created by Ahmed Khalaf on 10/23/25.
//

import SwiftUI
import SwiftData

@main
struct DripApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FinanceStore.self,
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
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
