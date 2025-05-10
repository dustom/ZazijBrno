//
//  ColorExtensions.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 10.05.2025.
//

import Foundation
import SwiftUI

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
