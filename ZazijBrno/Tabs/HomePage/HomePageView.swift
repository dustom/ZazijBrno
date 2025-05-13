//
//  HomePageView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import SwiftUI
import SwiftData
import MapKit


struct HomePageView: View {
    
    @StateObject private var homePageViewModel = HomePageViewModel()
    @EnvironmentObject var eventStore: EventStore
    @Environment(\.modelContext) var modelContext
    @Query private var savedEvents: [FavoriteEvent] = []
    @Environment(\.scenePhase) var scenePhase
    @State private var cameFromBackground = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    //MARK: saved/favorite events
                    favoriteEventsHeader
                    // a fallback and a hint to help user discover the app's functions
                    if homePageViewModel.shouldShowNoEventsSavedView(savedEvents: savedEvents) {
                        noSavedEventsView
                    } else {
                        savedEventsView
                    }
                    
                    //MARK: current events
                    todayEventsHeader
                    
                    // a current events view with fallback options
                    switch eventStore.status {
                    case .notStarted:
                        noEventsFoundView
                        
                    case .fetching:
                        ProgressView()
                        
                    case .success:
                        if homePageViewModel.shouldShowNoEventsHappeningView {
                            
                        } else {
                            todayEventsView
                        }
                        
                    case .failed:
                        noEventsFoundView
                    }
                }
                .scrollIndicators(.hidden)
                .preferredColorScheme(.dark)
                .navigationTitle("Přehled")
            }
            .scrollIndicators(.hidden)
            .refreshable {
                Task {
                    await reloadViewData()
                }
            }
        }
        // all events are loaded on appear only when there are none yet
        .onAppear() {
            if homePageViewModel.shouldLoadAllEvents(allEvents: eventStore.allEvents) {
                Task {
                    await reloadViewData()
                }
            }
        }
    }
    
    /// helper method that makes the operations needed to refresh the whole view
    private func reloadViewData() async {
        await eventStore.getAllEvents()
        homePageViewModel.refreshView(savedEvents: savedEvents, allEvents: eventStore.allEvents)
    }
    
    private var favoriteEventsHeader: some View {
        HStack {
            Text("Uložené akce")
                .font(.title2.bold())
            Spacer()
        }
        .padding([.top, .horizontal])
    }
    
    private var noSavedEventsView: some View {
        ContentUnavailableView(
            "Žádné uložené akce.",
            systemImage: "calendar.badge.plus",
            description: Text("Přejděte do záložky Akce a v detailu si přidejte svou první událost!")
        )
        .padding()
    }
    
    
    // a view with all the saved events presented in a side scroll view
    // the favorite events are presented based on the swift data and the ID
    // this approach guarantees that the data provided in the detail are always correct
    private var savedEventsView: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(homePageViewModel.favoriteEvents, id: \.self) { favoriteEvent in
                    NavigationLink {
                        EventDetailView(event: favoriteEvent,
                                        position: .camera(
                                            MapCamera(
                                                centerCoordinate: favoriteEvent.properties.location,
                                                distance: 2000
                                            )))
                    } label: {
                        SavedEventCellView(event: favoriteEvent)
                            .buttonStyle(.plain)
                            .padding(.trailing, 5)
                    }
                    
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
        }
        .onChange(of: savedEvents) {
            homePageViewModel.refreshView(savedEvents: savedEvents, allEvents: eventStore.allEvents)
        }
    }
    
    private var todayEventsHeader: some View {
        HStack {
            Text("Právě se děje")
                .font(.title2.bold())
            Spacer()
        }
        .padding()
    }
    
    private var noEventsFoundView: some View {
        ContentUnavailableView(
            "Nepodařilo se najít žádné akce.",
            systemImage: "exclamationmark.magnifyingglass",
            description: Text("Bohužel se nepodařilo nalézt žádné akce. Zkuste obnovit hledání potažením dolu.")
        ).padding()
    }
    
    private var noEventsHappeningView: some View {
        ContentUnavailableView(
            "Dnes se nekonají žádné akce",
            systemImage: "calendar.badge.exclamationmark",
            description: Text("Přejděte do záložky Akce a prohlédněte si nadcházející události!")
        )
        .padding()
    }
    
    // a view with events happening today
    private var todayEventsView: some View {
        LazyVStack {
            ForEach(homePageViewModel.todayEvents, id:\.self) { event in
                NavigationLink{
                    EventDetailView(event: event,
                                    position: .camera(
                                        MapCamera(
                                            centerCoordinate: event.properties.location,
                                            distance: 2000
                                        )))
                }label: {
                    HStack {
                        EventNavigationLinkView(event: event)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding(.horizontal)
                    }
                    .contentShape(Rectangle())
                    
                }
                .foregroundStyle(.primary)
                .background(.thinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
        }
    }
    
    
}

#Preview {
    HomePageView()
        .environmentObject(EventStore())
}
