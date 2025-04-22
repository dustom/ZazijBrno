//
//  Event.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import Foundation
import MapKit


// a struct for JSON parsing from and API call

struct FetchedEvents: Codable {
    let features: [Event]
}

struct Event: Codable, Hashable {
    let properties: EventDetails
}

struct EventDetails: Codable, Hashable {
    let id: Double
    let name: String
    let text: String?
    let tickets: String?
    let ticketsInfo: String?
    let images: URL?
    let url: URL
    let categories: String
    let latitude: Double
    let longitude: Double
    let dateFrom: Double
    let dateTo: Double
    
    //computed property used in map and map detail
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    //computed property of date that converts it from milliseconds (provided from an API) to seconds that is used in swift
    var dateFromConverted: Date {
        Date(timeIntervalSince1970: dateFrom / 1000)
    }
    
    var dateToConverted: Date {
        Date(timeIntervalSince1970: dateTo / 1000)
    }
    
    // computed property to determin whether the event last for a certain period or not
    var isSingleDayEvent: Bool {
        return dateFrom == dateTo
    }
    
    // computed property, that extracts the first category for easier filtering
    // possible TODO - make the app use ALL categories not just the primary one
    var primaryCategory: EventCategory? {
        let categoriesList = categories
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        return categoriesList
            .compactMap { rawCategory in
                EventCategory.allCases.first { $0.rawValue == rawCategory }
            }
            .first
    }
    
    
    // computed property to assing a specific symbol to an event
    var categorySymbol: String {
        primaryCategory?.symbolName ?? "questionmark"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name
        case text
        case tickets
        case ticketsInfo = "tickets_info"
        case images
        case url
        case categories
        case latitude
        case longitude
        case dateFrom = "date_from"
        case dateTo = "date_to"
    }
}
