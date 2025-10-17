//
//  SharedDefaults.swift
//  Habood
//
//  Created by yunlong chen on 2025/10/17.
//
import Foundation
import WidgetKit

/// Centralized helper for reading/writing values to the App Group.
enum SharedDefaults {
    static let suiteName = "group.com.habood.shared"
    static let userUIDKey = "userUID"

    /// Save current user's UID to the shared container and refresh widgets.
    static func save(uid: String) {
        let ud = UserDefaults(suiteName: suiteName)
        ud?.set(uid, forKey: userUIDKey)
        WidgetCenter.shared.reloadAllTimelines()   // ask all widgets to refresh
    }

    /// Remove UID (e.g., on sign-out) and refresh widgets.
    static func clearUID() {
        let ud = UserDefaults(suiteName: suiteName)
        ud?.removeObject(forKey: userUIDKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Read UID (if needed in the app)
    static func readUID() -> String? {
        UserDefaults(suiteName: suiteName)?.string(forKey: userUIDKey)
    }
}
