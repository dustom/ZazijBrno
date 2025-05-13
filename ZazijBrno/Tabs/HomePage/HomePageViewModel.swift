//
//  HomePageViewModel.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 21.04.2025.
//

import Foundation
import SwiftUI
import SwiftData


class HomePageViewModel: ObservableObject {
    
    @Published var todayEvents: [Event] = []
    @Published var favoriteEvents: [Event] = []
    
    /// a method that filters sorted events and keeps only those that are happening today
    @MainActor func getTodayEvents(allEvents: [Event]) {
        var events: [Event] = []
        for event in allEvents {
            if isEventToday(eventProperties: event.properties) {
                events.append(event)
            }
        }
        let sortedEvents = events.sorted { $0.properties.dateFrom < $1.properties.dateFrom }
        todayEvents = sortedEvents
    }
    
    /// a simple method to determine whether to load events if there are none present
    func shouldLoadAllEvents(allEvents: [Event]) -> Bool {
        return allEvents.isEmpty
    }
    
    func shouldShowNoEventsSavedView(savedEvents: [FavoriteEvent]) -> Bool {
        return savedEvents.isEmpty
    }
    
    var shouldShowNoEventsHappeningView: Bool {
        return todayEvents.isEmpty
    }
    
    /// a method that takes saved events (IDs), compares them to all events and returns an array of all saved events
    @MainActor func refreshView(savedEvents: [FavoriteEvent], allEvents: [Event]) {
        var events: [Event] = []
        for savedEvent in savedEvents {
            events.append(contentsOf: allEvents.filter { $0.properties.id == savedEvent.id })
        }
        favoriteEvents = events
        getTodayEvents(allEvents: allEvents)
    }
    
    /// a helper method that returns true if the event is happening today
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
