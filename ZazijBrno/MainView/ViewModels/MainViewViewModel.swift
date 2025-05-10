//
//  MainViewViewModel.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 23.04.2025.
//

import Foundation
@MainActor
class MainViewViewModel: ObservableObject {
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }
    
    private let fetcher = FetchEvents()
    private var fetchedEvents: FetchedEvents?
    @Published var allEvents: [Event] = []
    @Published var status: FetchStatus = .notStarted
    
    func getAllEvents() async {
        status = .fetching
        
        do {
            fetchedEvents = try await fetcher.fetchEvents()
            //making sure that fetchedEvents is corectly populated
            guard let events = fetchedEvents else {
                status = .failed(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data fetched."]))
                return
            }
            sortEventsByDate(fetchedEvents: events)
            status = .success
        } catch {
            status = .failed(error: error)
        }
    }
    
    // a helper method that sorts events based on their starting date
    private func sortEventsByDate(fetchedEvents: FetchedEvents) {
        allEvents = fetchedEvents.features.sorted { $0.properties.dateFrom < $1.properties.dateFrom }
    }
}
