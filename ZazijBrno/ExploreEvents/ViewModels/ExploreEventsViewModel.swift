//
//  EventsViewModel.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//


import Foundation


@MainActor
class ExploreEventsViewModel: ObservableObject {
    
    //en enum that helps with feedback to user and view management
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }
    
    private let fetcher = FetchEvents()
    private var fetchedEvents: FetchedEvents
    @Published var allEvents: [Event] = []
    @Published var eventsInInterval: [Event] = []
    
    @Published var status: FetchStatus = .notStarted
    
    
    //simple initializer to test and populate variables from sample JSON file
    init() {
        let decoder = JSONDecoder()
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "sample_events", withExtension: "json")!)
        fetchedEvents = try! decoder.decode(FetchedEvents.self, from: data)
    }
    
    
    // a method that makes and async API call and then creates a sorted and clipped array of events
    func getAllEvents() async {
        status = .fetching
        
        do {
            fetchedEvents = try await fetcher.fetchEvents()
            sortAndClipEventsByDate(fetchedEvents: fetchedEvents)
            status = .success
        } catch {
            status = .failed(error: error)
        }
    }
    
    
    // a method that takes advantage of the Double data type provided by the API call
    // it takes all events and checks whether they will start or have already started but hasn't ended yet
    // final list is then sorted by date where first item is the closes event
    // this method is used to filter events happening in a certain time period
    
    func filterEventsByDateInterval(startDate: Date, endDate: Date) {
        
        let startUnixMilliseconds = startDate.timeIntervalSince1970 * 1000
        let endUnixMilliseconds = endDate.timeIntervalSince1970 * 1000
        
        let filteredEvents = fetchedEvents.features.filter { event in
            let eventStart = event.properties.dateFrom
            let eventEnd = event.properties.dateTo
            
            return (eventStart >= startUnixMilliseconds && eventStart <= endUnixMilliseconds) ||
                   (eventStart <= startUnixMilliseconds && eventEnd >= startUnixMilliseconds)
        }
        
        let sortedEvents = filteredEvents.sorted {
            $0.properties.dateFrom < $1.properties.dateFrom
        }
        
        eventsInInterval = sortedEvents
    }
    
    // a simple method that filters and sorts only the events that will happen or are already happening
    func sortAndClipEventsByDate(fetchedEvents: FetchedEvents) {
        
        let todayUnixMilliseconds = Date().timeIntervalSince1970 * 1000
        
        let filteredEvents = fetchedEvents.features.filter {
            $0.properties.dateTo > todayUnixMilliseconds
        }
        
        let sortedClippedEvents = filteredEvents.sorted {
            $0.properties.dateFrom < $1.properties.dateFrom
        }
        
        allEvents = sortedClippedEvents
    }
}

// an extension used thourghout the whole app
// the API call provides a HTML scrape that has HTML entities in it, this just cleans them

extension String {
    func clean() -> String {
        var cleaned = self
        let entities = [
            "&nbsp;": " ",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'",
            "&#8211;" : "",
            "&#8220;" : "",
            "&#8230;" : "",
            "&#8221;" : ""
        ]
        entities.forEach { (entity, replacement) in
            cleaned = cleaned.replacingOccurrences(of: entity, with: replacement)
        }
        return cleaned
    }
}

