//
//  HomePageViewModel.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 21.04.2025.
//

import Foundation

@MainActor
class HomePageViewModel: ObservableObject {
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }
    
    private let fetcher = FetchEvents()
    private var fetchedEvents: FetchedEvents
    @Published var sortedAllEvents: [Event] = []
    @Published var todayEvents: [Event] = []
    @Published var status: FetchStatus = .notStarted
    
    //simple initializer to test and populate variables from sample JSON file
    init() {
        let decoder = JSONDecoder()
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "sample_events", withExtension: "json")!)
        fetchedEvents = try! decoder.decode(FetchedEvents.self, from: data)
    }
    
    
    // a method that filters sorted events and keeps only those that are happening today
    func getTodayEvents() {
        var events: [Event] = []
        for event in sortedAllEvents {
            if isEventToday(eventProperties: event.properties) {
                events.append(event)
            }
        }
        let sortedEvents = events.sorted { $0.properties.dateFrom < $1.properties.dateFrom }
        todayEvents = sortedEvents
    }
    
    
    
    // a method that make an async API call for all events and then sorts them
    func getAllEvents() async {
        status = .fetching
        
        do {
            fetchedEvents = try await fetcher.fetchEvents()
            sortEventsByDate(fetchedEvents: fetchedEvents)
            status = .success
        } catch {
            status = .failed(error: error)
        }
    }
    
    // a helper method that sorts events based on their starting date
    private func sortEventsByDate(fetchedEvents: FetchedEvents) {
        sortedAllEvents = fetchedEvents.features.sorted { $0.properties.dateFrom < $1.properties.dateFrom }
    }
    
    
    
    // a helper method that returns true if the event is happening today
    private func isEventToday(eventProperties: EventDetails) -> Bool {
        
        let dateFrom = eventProperties.dateFrom / 1000
        let dateTo = eventProperties.dateTo / 1000
        let todayUnix = Date().timeIntervalSince1970
        
        if todayUnix >= dateFrom && todayUnix <= dateTo {
            return true
        } else {
            return false
        }
    }
}
