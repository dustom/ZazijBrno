//
//  Constants.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 18.04.2025.
//

import Foundation
import SwiftUI

struct Constants {
    let brnoColor = Color(r: 255, g: 13, b: 1)
}

// converting color from 255 rgb to 0-1 model
extension Color {
    init(r: Int, g: Int, b: Int, a: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: a
        )
    }
}
