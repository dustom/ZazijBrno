//
//  FetchEvents.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import Foundation



// a simple class that makes an API call and receives a JSON file

class FetchEvents {
    private enum FetchError: Error {
        case badResponse
    }
    
    
    func fetchEvents() async throws -> FetchedEvents  {
        
        // URL that returns all events happening in Brno
        let baseURL = URL(string: "https://services6.arcgis.com/fUWVlHWZNxUvTUh8/arcgis/rest/services/Events/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")!
        
        
        let (data, response) = try await URLSession.shared.data(from: baseURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        let event = try decoder.decode(FetchedEvents.self, from: data)
        
        return event
    }
}
