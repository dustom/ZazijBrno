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
    private var fetchedEvents: FetchedEvents
    @Published var allEvents: [Event] = []
    @Published var status: FetchStatus = .notStarted
    
    //simple initializer to test and populate variables from sample JSON file
    init() {
        let decoder = JSONDecoder()
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "sample_events", withExtension: "json")!)
        fetchedEvents = try! decoder.decode(FetchedEvents.self, from: data)
    }
    
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
        allEvents = fetchedEvents.features.sorted { $0.properties.dateFrom < $1.properties.dateFrom }
    }
}
