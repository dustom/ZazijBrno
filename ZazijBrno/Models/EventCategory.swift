//
//  EventCategory.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import Foundation


// an enum that is used to assing a string and a symbol to a specific event category
enum EventCategory: String, CaseIterable, Identifiable {
    case music = "Hudba"
    case education = "Veletrhy / vzdělávací"
    case theater = "Divadlo"
    case family = "Pro rodiny"
    case guidedTour = "Komentované prohlídky"
    case exhibition = "Výstava"
    case festival = "Festivaly"
    case featured = "TOP akce"
    case nightlife = "Noční život"
    case food = "Gastronomické"
    case literature = "Literatura"
    case dance = "Tanec"
    case sports = "Sport"
    case folklore = "Folklor"
    
    var id: Self { self }
    
    var symbolName: String {
        switch self {
        case .music: return "music.note"
        case .education: return "book.closed"
        case .theater: return "theatermasks"
        case .family: return "figure.and.child.holdinghands"
        case .guidedTour: return "person.2"
        case .exhibition: return "photo.on.rectangle"
        case .festival: return "party.popper"
        case .featured: return "star"
        case .nightlife: return "moon.stars"
        case .food: return "fork.knife"
        case .literature: return "text.book.closed"
        case .dance: return "figure.dance"
        case .sports: return "sportscourt"
        case .folklore: return "guitars"
        }
    }
}
