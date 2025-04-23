//
//  EventsViewModel.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//


import Foundation

class ExploreEventsViewModel: ObservableObject {
    
    @Published var allEvents: [Event] = []
    @Published var eventsInInterval: [Event] = []
    
    // a method that takes advantage of the Double data type provided by the API call
    // it takes all events and checks whether they will start or have already started but hasn't ended yet
    // final list is then sorted by date where first item is the closes event
    // this method is used to filter events happening in a certain time period
    
    func filterEventsByDateInterval(allEvents: [Event], startDate: Date, endDate: Date) {
        
        let startUnixMilliseconds = startDate.timeIntervalSince1970 * 1000
        let endUnixMilliseconds = endDate.timeIntervalSince1970 * 1000
        
        let filteredEvents = allEvents.filter { event in
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

