//
//  Item.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//

import Foundation
import SwiftData

/**
 SwiftData-backed settings entity.

 ## Overview
 Stores local-only preferences used by SettingsView.

 ## Persistence
 Managed with SwiftData `ModelContext`.
 */

@Model
final class SettingsItem {
    var darkMode: Bool
    var notifications: Bool
    var reminderHour: Int
    var reminderMinute: Int
    
    init(darkMode: Bool = false,
         notifications: Bool = false,
         reminderHour: Int = 9,
         reminderMinute: Int = 0) {
        self.darkMode = darkMode
        self.notifications = notifications
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
    }
}
