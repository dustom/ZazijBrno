//
//  ContentView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject var eventStore = EventStore()
    @Environment(\.scenePhase) var scenePhase
    @State private var cameFromBackground = true
    
    var body: some View {
        TabView {
            HomePageView()
                .tag("Overview")
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                .toolbarBackgroundVisibility(.visible, for: .tabBar)
                .tabItem {
                    Label("Přehled", systemImage: "house")
                }
            
            ExploreEventsView()
                .tag("Akce")
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                .toolbarBackgroundVisibility(.visible, for: .tabBar)
                .tabItem {
                    Label("Akce", systemImage: "calendar")
                }
        }
        .environmentObject(eventStore)
        
        // load all events on appear
        .onAppear() {
            if scenePhase == .active {
                if cameFromBackground {
                    Task {
                        await eventStore.getAllEvents()
                    }
                }
                cameFromBackground = false
            } else if scenePhase == .background {
                cameFromBackground = true
            }
        }
        .tint(Constants.brnoColor)
    }
}

#Preview {
    MainView()
}
