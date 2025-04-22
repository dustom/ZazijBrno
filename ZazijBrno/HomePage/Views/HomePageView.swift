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
    
    @StateObject private var vm = HomePageViewModel()
    @Environment(\.modelContext) var modelContext
    @Query private var savedEvents: [FavoriteEvent] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    //MARK: saved/favorite events
                    HStack {
                        Text("Uložené akce")
                            .font(.title2.bold())
                        Spacer()
                    }
                    .padding([.top, .horizontal])
                    
                    // a fallback and a hint to help user discover the app's functions
                    if savedEvents.isEmpty {
                        ContentUnavailableView(
                            "Žádné uložené akce.",
                            systemImage: "calendar.badge.plus",
                            description: Text("Přejděte do záložky Akce a v detailu si přidejte svou první událost!")
                        )
                        .padding()
                    } else {
                        savedEventsView
                    }
                    
                    //MARK: current events
                    HStack {
                        Text("Právě se děje")
                            .font(.title2.bold())
                        Spacer()
                    }
                    .padding()
                    
                    
                    // a current events view with fallback options
                    switch vm.status {
                    case .notStarted:
                        ContentUnavailableView("Objevte nové akce.", systemImage: "magnifyingglass", description: Text("Potažením dolu obnovte stránku a objevte nové akce."))
                    case .fetching:
                        ProgressView()
                    case .success:
                        
                        if vm.todayEvents.isEmpty {
                            ContentUnavailableView(
                                "Dnes se nekonají žádné akce",
                                systemImage: "calendar.badge.exclamationmark",
                                description: Text("Přejděte do záložky Akce a prohlédněte si nadcházející události!")
                            )
                            .padding()
                        } else {
                            todayEventsView
                        }
                        
                    case .failed:
                        ContentUnavailableView("Nepodařilo se najít žádné akce.", systemImage: "exclamationmark.magnifyingglass", description: Text("Bohužel se nepodařilo nalézt žádné akce. Zkuste obnovit hledání potažením dolu."))
                    }
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    refreshView()
                }
                .preferredColorScheme(.dark)
                .navigationTitle("Přehled")
            }
            .scrollIndicators(.hidden)
            .refreshable {
                refreshView()
            }
        }
    }
    
    // a helper method used to refresh the page
    private func refreshView() {
        Task {
            await vm.getAllEvents()
            vm.getTodayEvents()
        }
    }
    
    // a view with all the saved events presented in a side scroll view
    // the favorite events are presented based on the swift data and the ID
    // this approach guarantees that the data provided in the detail are always correct
    private var savedEventsView: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(savedEvents) { event in
                    
                    // the id is unique so it looks only for the first occurance
                    if let favoriteEvent = vm.sortedAllEvents.first(where: { $0.properties.id == event.id }) {
                        NavigationLink {
                            EventDetailView(event: favoriteEvent,
                                            position: .camera(
                                                MapCamera(
                                                    centerCoordinate: favoriteEvent.properties.location,
                                                    distance: 2000
                                                )))
                            .modelContext(modelContext)
                        } label: {
                            SavedEventCellView(event: favoriteEvent)
                                .buttonStyle(.plain)
                                .padding(.trailing, 5)
                        }
                        
                        .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // a view with events happening today
    @MainActor
    private var todayEventsView: some View {
        LazyVStack {
            ForEach(vm.todayEvents, id:\.self) { event in
                NavigationLink{
                    EventDetailView(event: event,
                                    position: .camera(
                                        MapCamera(
                                            centerCoordinate: event.properties.location,
                                            distance: 2000
                                        )))
                    .modelContext(modelContext)
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
}
