//
//  EventDetailView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import SwiftUI
import MapKit
import Foundation
import SafariServices
import SwiftData


// the most important view that presents user with the event details with the ability to save it to "favorites"

struct EventDetailView: View {
    @Environment(\.modelContext) var modelContext
    @State private var error: Error?
    @State private var showErrorAlert = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    @Query private var savedEvents: [FavoriteEvent] = []
    var event: Event
    @State private var showInfo = false
    @State private var showWebView = false
    @State var position: MapCameraPosition
    @State private var isFavorite: Bool = false
    
    var body: some View {
        
        ZStack{
            
            ScrollViewReader { proxy in
                ScrollView {
            
                    //MARK: event image
                    VStack{
            
                        eventImage
                        
                    }
                    
                    //MARK: event name row
                    VStack {
                        Text(event.properties.name.clean())
                            .font(.title)
                            .padding(.bottom, 3)
                        
                        
                        //MARK: date(s) row
                        // if the event last only one day, the view shows only that date not a range
                        if event.properties.isSingleDayEvent {
                            Text(event.properties.dateFromConverted, style: .date)
                                .foregroundStyle(Constants.brnoColor)
                                .font(.title3)
                        } else {
                            HStack{
                                Text(event.properties.dateFromConverted, style: .date)
                                Text(" - ")
                                Text(event.properties.dateToConverted, style: .date)
                            }
                            .foregroundStyle(Constants.brnoColor)
                            .font(.title3)
                        }
                        
                        //MARK: tickets and prices box
                        if let tickets = event.properties.tickets {
                            DetailRow(annotation: "Vstupné", value: tickets)
                                .padding(.bottom, 5)
                                .id("Description")
                        }
                        
                        //MARK: categories box
                        DetailRow(annotation: "Kategorie", value: event.properties.categories)
                            .padding(.bottom, 5)
                        
                        //MARK: event information box
                        if let description = event.properties.text?.clean() {
                            ClickableDetailItemView(isSelectionPresented: $showInfo, itemName: "Informace od pořadatele", itemData: description)
                                .padding(.bottom, 5)
                                .onChange(of: showInfo) {
                                    
                                    //this is a workaround to make sure the view is loaded before scrolling to ensure proper behavior
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        scrollToItem("Description", proxy: proxy)
                                    }
                                }
                        }
                        
                        //MARK: map detail
                        map
                        
                        
                        //MARK: visit website button
                        Button{
                            showWebView = true
                        } label: {
                            HStack{
                                Text("Navštívit webové stránky")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(Constants.brnoColor)
                                    .clipShape(.rect(cornerRadius: 15))
                                    .shadow(color: .gray, radius: 2)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.bottom, 80)
                        .sheet(isPresented: $showWebView) {
                            SafariView(url: event.properties.url)
                        }
                        
                    }
                    .padding()
                    
                    
                    //MARK: save event error alert
                    .alert("Uložení selhalo", isPresented: $showErrorAlert) {
                        Button("OK", role: .cancel) {
                            error = nil
                        }
                    } message: {
                        Text(error?.localizedDescription ?? "Stala se naznámá chyba")
                    }
                    
                    
                    //MARK: Toolbar item
                    .toolbar{
                        ToolbarItem {
                            Button {
                                toggleFavorite()
                                
                            } label: {
                                Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                                    .foregroundStyle(Constants.brnoColor)
                            }
                            .padding()
                        }
                    }
                    
                }
                
                
                // a simple check whether the event is already among saved events
                .onAppear() {
                    if savedEvents.contains(where: { $0.id == event.properties.id }) {
                        isFavorite = true
                    }
                }
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
                .environment(\.colorScheme, .dark)
                .scrollIndicators(.hidden)
                .toolbarBackground(.automatic)
            }
        }
        .overlay(
            successMessageNotification
        )
    }
    
    //MARK: event image view
    // an async image that is loaded from the provided URL
    // when there is an error or the URL is missing an alternative option is provided to not hinder the desing
    private var eventImage: some View {
        Group{
            if let imageUrl = event.properties.images {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .overlay {
                                LinearGradient(stops: [Gradient.Stop(color: .clear, location: 0.5), Gradient.Stop(color: .black, location: 1)], startPoint: .top, endPoint: .bottom)
                            }
                    case .failure:
                        fallbackImage
                    @unknown default:
                        fallbackImage
                    }
                }
            }
            else {
                fallbackImage
            }
        }
    }
    
    //MARK: fallback image view
    // fallback image that is used in case of missing image from the API or in case of an error
    private var fallbackImage: some View {
        Image("brno")
            .resizable()
            .scaledToFill()
            .overlay {
                LinearGradient(stops: [Gradient.Stop(color: .clear, location: 0.5), Gradient.Stop(color: .black, location: 1)], startPoint: .top, endPoint: .bottom)
            }
    }
    
    
    
    //MARK: map detail view
    // a map detail that shows a piece of a map with the exact location of the event
    private var map: some View {
        NavigationLink{
            // when the map is tapped, it presents a wholepage view of a map with the event location
            EventMapView(event: event,
                         position: .camera(
                            MapCamera(
                                centerCoordinate: event.properties.location,
                                distance: 1000
                            )))
            
        } label: {
            Map(position: $position) {
                Annotation(event.properties.name.clean(), coordinate: event.properties.location) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(Constants.brnoColor)
                        .font(.largeTitle)
                        .imageScale(.large)
                }
                .annotationTitles(.hidden)
            }
            .frame(height: 125)
            .clipShape(.rect(cornerRadius: 15))
            .overlay (alignment: .trailing) {
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .font(.title)
                    .padding(.trailing, 5)
                    .foregroundStyle(Constants.brnoColor)
            }
            
        }
        .padding(.bottom, 5)
    }
    
    //MARK: successMessageNotification
    //a simple succes message that informs the user about a succesful action of event manipulation
    // message slides from the top, stays for 2 seconds and then it goes away
    private var successMessageNotification: some View {
        Group {
            if showSuccessMessage {
                Text(successMessage)
                    .padding()
                    .background(.thinMaterial)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .task(id: showSuccessMessage) {
            guard showSuccessMessage else { return }
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeOut) {
                showSuccessMessage = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 20)
        .animation(.spring(), value: showSuccessMessage)
    }
    
    //MARK: toggleFavorite method
    // a helper method that handles addition and deletion of events to favorites
    private func toggleFavorite() {
        do {
            
            isFavorite.toggle()
            
            //if the event is to be favorite, it is saved to swift data for persistance and a succes message is changed
            if isFavorite {
                modelContext.insert(FavoriteEvent(id: event.properties.id))
                successMessage = "Přidáno do uložených"
            } else {
                //if the event should be deleted a FavoriteEvent is fetched based on its ID
                let fetchDescriptor = FetchDescriptor<FavoriteEvent>(
                    predicate: #Predicate { $0.id == event.properties.id }
                )
                
                //if it actually exists, it is then deleted from the database
                if let favoriteToDelete = try modelContext.fetch(fetchDescriptor).first {
                    modelContext.delete(favoriteToDelete)
                }
                successMessage = "Odebráno z uložených"
            }
            
            
            //if everything is succesful the data are saved and a success message is shown with haptic feedback
            try modelContext.save()
            showSuccessMessage = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
        } catch {
            // if there is an error, the user is alerted and the change is reverted to ensure persistance
            isFavorite.toggle()
            self.error = error
            self.showErrorAlert = true
        }
    }
    
    //MARK: scrollToItem method
    // a method that allows to scroll to a specific point on the view
    private func scrollToItem(_ id: String, proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(id, anchor: .top)
        }
    }
    
    //MARK: DetailRow view
    // a simple view to display details
    struct DetailRow: View {
        var annotation: String
        var value: String
        
        var body: some View {
            
            VStack(alignment: .leading) {
                
                Text(annotation)
                    .font(.headline)
                
                HStack {
                    Text(value)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
            }
            .padding()
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Constants.brnoColor, lineWidth: 1.5)
            )
        }
    }
    
    //MARK: SafariView
    // a simple safari view that allows to display a web page without letting the user leave the app :)
    struct SafariView: UIViewControllerRepresentable {
        let url: URL
        
        func makeUIViewController(context: Context) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }
        
        func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
    }
}


#Preview {
    
    let event = Event(
        properties: EventDetails(
            id: 125,
            name: "Nazareth /UK/ v Brně 2026",
            text: "Do ČR se vrací renomovaná hardrocková kapela Nazareth! V únoru 2026 potěší fanoušky v brněnském Sonu a&nbsp;o&nbsp;den později v Aule Gong Ostrava.Nazareth je skotská rocková skupina, známá mnoha rockovými hity, stejně jako skvělou cover verzí balady Love Hurts z&nbsp;poloviny 70.&nbsp;let. Skupina byla založena ve městě Dunfermline ze zbytků poloprofesionální místní kapely The Shadettes (původně Mark V&nbsp;a&nbsp;The Red Hawks) zpěvákem Danem McCaffertym, kytaristou Mannym Charltonem, basákem Petem Agnewem a&nbsp;bubeníkem Darrellem Sweetem. Jméno získali ze skladby The Weight od skupiny The Band. V&nbsp;roce 1970 se skupina přesunula do Londýna, kde roku 1971 vydala své první, stejnojmenné album. Po získání pozornosti díky albu Exercises z&nbsp;roku 1972, Nazreth vydali další album Razamanaz na začátku roku 1973.Skladby jako Broken Down Angel a&nbsp;Bad Bad Boy se umístily v&nbsp;britském žebříčku Top 10 list. Poté následovalo album Loud N Proud na konci roku 1973, které obsahovalo hit This Flight Tonight, původně od Joni Mitchell. Roku 1974 vydali album Rampant, které bylo neméně úspěšné, třebaže neobsahovalo žádný singl. Další skladba (neobjevuje se na žádném albu), opět cover verze, tentokrát skladby My White Bicycle, se na začátku roku 1975 umístila v&nbsp;UK Top 20. Album Hair of the Dog bylo vydáno roku 1975. Titulní skladba (populárně, i&nbsp;když nesprávně známá jako „Now You`re Messing With a&nbsp;Son of a&nbsp;Bitch“) se stala základem rockových rádií 70.&nbsp;let. Americké vydání alba obsahuje skladbu Love Hurts, původně od The Everly Brothers a&nbsp;také nahranou Royem Orbisonem. Tato skladba byla ve Spojeném království a&nbsp;USA vydána jako singl. V&nbsp;USA byla oceněna jako platinová. Je to jediná skladba od Nazareth, která se umístila v&nbsp;americkém Top Ten.V létě 2013 Dan McCafferty oznámil, že ze zdravotních důvodů opouští kapelu. V&nbsp;únoru 2014 jej nahradil Linton Osborne, avšak v&nbsp;prosinci 2014 byla kapela kvůli Osbornově nemoci nucena zrušit několik koncertů a&nbsp;odložit turné po Spojeném království. V&nbsp;lednu Osborne na svém Facebooku oznámil odchod z&nbsp;Nazareth a&nbsp;o&nbsp;měsíc později kapela, kterou aktuálně tvoří její spoluzakladatel Pete Agnew (baskytara), jeho syn Lee Agnew (bicí) a&nbsp;Jimmy Murrison (kytara, v&nbsp;kapele působí již od 1994) na webu ohlásila nového zpěváka, kterým je Carl Sentance. Sentance spolupracoval s mnoha slavnými formacemi a&nbsp;hudebníky, a&nbsp;to například s&nbsp; Foreigner, Dio a&nbsp;Black Sabbath a&nbsp;byl frontmanem známé švýcarské skupiny Krokus.",
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
    
    EventDetailView(event: event,
                    position: .camera(
                        MapCamera(
                            centerCoordinate: event.properties.location,
                            distance: 1000
                        )))
}
