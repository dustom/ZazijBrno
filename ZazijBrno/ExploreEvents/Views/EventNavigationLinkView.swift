//
//  EventNavigationLinkView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import SwiftUI

struct EventNavigationLinkView: View {
    let k = Constants()
    var event: Event
    var isDateDisplayed: Bool?
    
    var body: some View {
        HStack {
            
            //MARK: category symbol
            // an event category symbol
            HStack{
                Image(systemName: event.properties.categorySymbol)
                    .font(.largeTitle)
                    .padding()
                    .foregroundStyle(k.brnoColor)
            }
            .frame(width: 80)
            
            //MARK: event name
            VStack(){
                HStack{
                    Text(event.properties.name.clean())
                        .padding(.bottom, 5)
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                
                //MARK: event date
                // if the event last only one day, the view shows only that date not a range
                if let showDate = isDateDisplayed {
                    if showDate {
                        HStack{
                            if event.properties.isSingleDayEvent {
                                Text(event.properties.dateFromConverted, style: .date)
                                
                            } else {
                                Text(event.properties.dateFromConverted, format: .dateTime.day().month(.defaultDigits).year())
                                Text(" - ")
                                Text(event.properties.dateToConverted,format: .dateTime.day().month(.defaultDigits).year())
                            }
                            Spacer()
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    }
                }
                
            }
            .padding(3)
        }
        .frame(maxHeight: 100)
    }
}

#Preview {
    
    let event = Event(
        properties: EventDetails(
            id: 125,
            name: "Nazareth /UK/ v Brně 2026",
            text: "Do ČR se vrací renomovaná hardrocková kapela Nazareth! V únoru 2026 potěší fanoušky v brněnském Sonu.",
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
    
    
    EventNavigationLinkView(event: event, isDateDisplayed: true)
}

