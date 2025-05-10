//
//  SavedEventDetailView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 20.04.2025.
//

import SwiftUI

struct SavedEventCellView: View {
    let event: Event
    var body: some View {
        VStack {
            HStack{
                // MARK: event image
                eventImage
                
                Spacer()
                
                //MARK: event date
                HStack(){
                
                    Text(event.properties.dateFromConverted,
                         format: .dateTime.day().month(.defaultDigits))
                        .font(.largeTitle)
                        .foregroundStyle(Constants.brnoColor)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
            
            Spacer()
            
            //MARK: event name
            Text(event.properties.name.clean())
                .font(.title2)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)
            
            
        }
        .padding()
        .frame(width: 230, height: 200)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .preferredColorScheme(.dark)
    }
    
    // an async image with fallback options
    // when the URL image load fails or the URL isn't available at all it shows a default image
    private var eventImage : some View {
        Group{
            if let imageUrl = event.properties.images {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 90, height: 90)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    case .failure:
                        fallbackImage
                    @unknown default:
                        fallbackImage
                    }
                }
            } else {
                fallbackImage
            }
        }
    }
    
    
    // a dafult image of Brno to make sure the view isn't empty
    private var fallbackImage: some View {
        Image("brno")
            .resizable()
            .scaledToFill()
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
}

#Preview {
    
    let event = Event(
        properties: EventDetails(
            id: 125,
            name: "Nazareth /UK/ v Brně 2026",
            text: "Do ČR se vrací renomovaná hardrocková kapela Nazareth! V únoru 2026 potěší fanoušky v brněnském Sonu a&nbsp;o&nbsp;den později v Aule Gong Ostrava.Nazareth je skotská rocková skupina, známá mnoha rockovými hity, stejně jako skvělou cover verzí balady Love Hurts z&nbsp;poloviny 70.&nbsp;let.",
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
    
    SavedEventCellView(event: event)
}
