//
//  ContentView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) var modelContext
    let k = Constants()
    var body: some View {
        TabView {
            HomePageView()
                .tag("Overview")
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                .toolbarBackgroundVisibility(.visible, for: .tabBar)
                .tabItem {
                    Label("Přehled", systemImage: "house")
                }
                .modelContext(modelContext)
            
            ExploreEventsView()
                .tag("Akce")
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                .toolbarBackgroundVisibility(.visible, for: .tabBar)
                .tabItem {
                    Label("Akce", systemImage: "calendar")
                }
                .modelContext(modelContext)
        }
        .tint(k.brnoColor)
    }
}

#Preview {
    MainView()
}
