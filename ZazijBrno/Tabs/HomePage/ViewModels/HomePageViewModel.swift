//
//  HomePageViewModel.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 21.04.2025.
//

import Foundation


class HomePageViewModel: ObservableObject {
    
    @Published var sortedAllEvents: [Event] = []
    @Published var todayEvents: [Event] = []
    
    
    // a method that filters sorted events and keeps only those that are happening today
    func getTodayEvents(allEvents: [Event]) {
        var events: [Event] = []
        for event in allEvents {
            if isEventToday(eventProperties: event.properties) {
                events.append(event)
            }
        }
        let sortedEvents = events.sorted { $0.properties.dateFrom < $1.properties.dateFrom }
        todayEvents = sortedEvents
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
