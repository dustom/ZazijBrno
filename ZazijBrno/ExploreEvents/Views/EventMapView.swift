//
//  EventMapView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 19.04.2025.
//

import SwiftUI
import MapKit

// full screen map view with a pin on the event location
struct EventMapView: View {
    let k = Constants()
    var event: Event
    @State var position: MapCameraPosition
    
    var body: some View {
        Map(position: $position) {
            Annotation(event.properties.name.clean(), coordinate: event.properties.location) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(k.brnoColor)
                    .font(.largeTitle)
                    .imageScale(.large)
            }
            .annotationTitles(.hidden)
        }
        .toolbarBackground(.automatic)
    }
}

#Preview {
    
    let event = Event(
        properties: EventDetails(
            id: 125,
            name: "Nazareth /UK/ v Brně 2026",
            text: "Do ČR se vrací renomovaná hardrocková kapela Nazareth!",
            tickets: "Dospeli 250 Kc",
            ticketsInfo: "",
            images: URL(string: "https://www.gotobrno.cz/wp-content/uploads/2025/03/naz_bar_photo_2022_xx-scaled.jpg"),
            url: URL(string: "https://www.gotobrno.cz/akce/nazareth-uk-v-brne-2026/")!,
            categories: "Hudba",
            latitude: 49.20956995479473,
            longitude: 16.588867496820058,
            dateFrom: 1772064000000,
            dateTo: 1772064000000
        ))
    
    EventMapView(event: event, position: .camera(
        MapCamera(
            centerCoordinate: event.properties.location,
            distance: 1500
        )))
}
