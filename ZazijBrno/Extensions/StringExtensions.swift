//
//  StringExtensions.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 10.05.2025.
//

import Foundation

// an extension used thourghout the whole app
// the API call provides a HTML scrape that has HTML entities in it, this just cleans them

extension String {
    func clean() -> String {
        var cleaned = self
        let entities = [
            "&nbsp;": " ",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'",
            "&#8211;" : "",
            "&#8220;" : "",
            "&#8230;" : "",
            "&#8221;" : ""
        ]
        entities.forEach { (entity, replacement) in
            cleaned = cleaned.replacingOccurrences(of: entity, with: replacement)
        }
        return cleaned
    }
}
