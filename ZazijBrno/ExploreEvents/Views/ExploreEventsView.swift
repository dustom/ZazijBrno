//
//  ExploreEventsView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import SwiftUI
import MapKit

// a view with all the events provided by the API call
// it allows to search and filter items based on date, category and text search

struct ExploreEventsView: View {
    @Environment(\.modelContext) var modelContext
    var k = Constants()
    @StateObject private var vm = ExploreEventsViewModel()
    @State private var searchText: String = ""
    @State private var typingLocation: Bool = false
    @State private var events: [Event] = []
    @State private var searchedEvents: [Event] = []
    @State private var selectedEvents: Set<EventCategory> = Set(EventCategory.allCases)
    @State private var isFilterOptionsPresented: Bool = false
    @State private var isDatePickerPresented: Bool = false
    @State private var selectedDateFrom: Date = Date()
    @State private var selectedDateTo: Date = Date()
    @State private var isDateFilterActive: Bool = false
    
    
    var body: some View {
        
        
        NavigationStack{
            
            //MARK: main view with fallbacks
            // the main view with error handling using ContentUnavailable fallbacks
            Group {
                switch vm.status {
                case .notStarted:
                    ContentUnavailableView("Objevte nové akce.", systemImage: "magnifyingglass", description: Text("Potažením dolu obnovte stránku a objevte nové akce."))
                case .fetching:
                    ProgressView()
                case .success:
                    mainView
                case .failed:
                    ContentUnavailableView("Nepodařilo se najít žádné akce.", systemImage: "exclamationmark.magnifyingglass", description: Text("Bohužel se nepodařilo nalézt žádné akce. Zkuste obnovit hledání potažením dolu."))
                }
            }
            .navigationTitle("Akce")
            
            //MARK: tooblar items
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        isFilterOptionsPresented = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                    Button{
                        isDatePickerPresented = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
        }
        
        
        // a sheet with date interval picker is presented after tapping on the calendar icon in the toolbar
        .sheet(isPresented: $isDatePickerPresented, content: {
            DatePickerView(dateFrom: $selectedDateFrom, dateTo: $selectedDateTo, isDateFilterActive: $isDateFilterActive)
                .presentationDetents([.medium])
        })
       
        // a sheet with filter options is presented after tapping on the filter icon in the toolbar
        .sheet(isPresented: $isFilterOptionsPresented, content: {
            EventFilterOptionsView(selectedOptions: $selectedEvents)
        })
        
        
        .tint(k.brnoColor)
        .preferredColorScheme(.dark)
        .onAppear() {
            refreshResults()
        }
        .refreshable {
            refreshResults()
        }
        .searchable(text: $searchText, isPresented: $typingLocation, prompt: "Vyhledat akci podle názvu..." )
        
        // this is an important part that handles the date filter activation
        .onChange(of: isDateFilterActive) {
            setFilter()
        }
    }
    
    
    // a computed property that simply filters event based on the selected categories
    private var filteredEvents: [Event] {
        events.filter {event in
            selectedEvents.contains { $0.rawValue == event.properties.primaryCategory?.rawValue }
        }
    }
    
    // a method that filters events based on the selected dates
    private func setFilter() {
        if isDateFilterActive {
                vm.filterEventsByDateInterval(startDate: selectedDateFrom, endDate: selectedDateTo)
                events = vm.eventsInInterval
        } else {
            refreshResults()
        }
    }
    
    // a simple helper method that refreshes the data on the view
    private func refreshResults() {
        Task {
            await vm.getAllEvents()
            events = vm.allEvents
        }
    }
    
    // a simple helper method that filters the events based on the search term
    private func searchEvents() {
        searchedEvents = filteredEvents.filter {
            $0.properties.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    
    //MARK: main view definition
    private var mainView: some View {
        
        Group{
            
            //a simple logic that makes sure the right data are presented
            
            // if the user didnt search and there are events to be displayed, all the filteredEvents are presented
            // the filteredEvents contains events based on the category filter (the default is ofc All categories)
            if searchText.isEmpty && !events.isEmpty {
                
                EventsView(events: filteredEvents)
                    .modelContext(modelContext)

                // if the user searched for something using the search bar, searchedEvents are presented
            } else if !searchedEvents.isEmpty {
                
                EventsView(events: searchedEvents)
                    .modelContext(modelContext)
                
                // if the search gives no results, the ContentUnavailableView is presented
            } else if searchedEvents.isEmpty{
                ContentUnavailableView("Nebyly nalezeny žádné akce obsahující: " + " \(searchText)", systemImage: "exclamationmark.magnifyingglass", description: Text("Bohužel se nepodařilo nalézt žádné akce. Zkuste vyhledat jiný název."))
                
                //and if there are no events based on the category filter the ContentUnavailableView is presented
            } else {
                ContentUnavailableView("Nebyly nalezeny žádné akce.", systemImage: "exclamationmark.magnifyingglass", description: Text("Bohužel se nepodařilo nalézt žádné akce. Zkuste obnovit hledání potažením dolu."))
            }
        }
        
        // to ensure seamless search, with every typed character the search is updated
        .onChange(of: searchText) {
            searchEvents()
        }
    }
    
    // a view that displays a list with all provided events
    
    @MainActor
    struct EventsView: View {
        @Environment(\.modelContext) var modelContext
        var events: [Event]
        
        var body: some View {
            List {
                ForEach (events, id:\.self) { event in
                    NavigationLink() {
                        EventDetailView(event: event,
                                        position: .camera(
                                            MapCamera(
                                                centerCoordinate: event.properties.location,
                                                distance: 2000
                                            )))
                        .modelContext(modelContext)
                    } label: {
                        EventNavigationLinkView(event: event, isDateDisplayed: true)
                            .padding(5)
                    }
                }
            }
        }
    }
}


#Preview {
    ExploreEventsView()
}
