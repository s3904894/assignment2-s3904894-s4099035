//
//  Item.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//

import Foundation
import SwiftData

@Model
final class SettingsItem {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
