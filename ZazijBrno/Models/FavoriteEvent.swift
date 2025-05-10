//
//  FavoriteEvent.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import Foundation
import SwiftData

// SwiftData persisstance class - it's just an ID to save memory usage

@Model
final class FavoriteEvent: Identifiable {
    #Unique<FavoriteEvent>([\.id])
    
    var id: Double
    
    init(id: Double) {
        self.id = id
    }
    
}
