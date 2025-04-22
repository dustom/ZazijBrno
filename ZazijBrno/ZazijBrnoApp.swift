//
//  ZazijBrnoApp.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import SwiftUI
import SwiftData

@main
struct ZazijBrnoApp: App {
    
    // a shared model container for the whole app to prived just one source of truth
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteEvent.self
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
            MainView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
        
    }
    
}
