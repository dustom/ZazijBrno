//
//  FetchStatus.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 12.05.2025.
//

import Foundation
enum FetchStatus {
    case notStarted
    case fetching
    case success
    case failed(error: Error)
}
