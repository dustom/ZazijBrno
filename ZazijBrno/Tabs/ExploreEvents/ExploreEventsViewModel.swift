//
//  EventsViewModel.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//


import Foundation

class ExploreEventsViewModel: ObservableObject {
    
    @Published var filteredEvents: [Event] = []
    @Published var searchedEvents: [Event] = []
    
    // a method that takes advantage of the Double data type provided by the API call
    // it takes all events and checks whether they will start or have already started but hasn't ended yet
    // final list is then sorted by date where first item is the closes event
    // this method is used to filter events happening in a certain time period
    
    func filterEventsByDateInterval(allEvents: [Event], startDate: Date, endDate: Date) {
        
        let startUnixMilliseconds = startDate.timeIntervalSince1970 * 1000
        let endUnixMilliseconds = endDate.timeIntervalSince1970 * 1000
        
        let filteredEventsInInterval = allEvents.filter { event in
            let eventStart = event.properties.dateFrom
            let eventEnd = event.properties.dateTo
            
            return (eventStart >= startUnixMilliseconds && eventStart <= endUnixMilliseconds) ||
            (eventStart <= startUnixMilliseconds && eventEnd >= startUnixMilliseconds)
        }
        
        let sortedEvents = filteredEventsInInterval.sorted {
            $0.properties.dateFrom < $1.properties.dateFrom
        }
        
        filteredEvents = sortedEvents
    }
    
    func filterEvents (allEvents: [Event], selectedCategories: Set<EventCategory>) {
        filteredEvents = allEvents.filter {event in
            selectedCategories.contains { $0.rawValue == event.properties.primaryCategory?.rawValue }
        }
    }
    
    // a simple helper method that filters the events based on the search term
    func searchEvents(for searchText: String) {
        searchedEvents = filteredEvents.filter {
            $0.properties.name.lowercased().contains(searchText.lowercased())
        }
    }
    
}

