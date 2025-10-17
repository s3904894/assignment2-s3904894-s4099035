//
//  AppUser.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//  Documented by Yunlong Chen



import Foundation
import FirebaseAuth

/// A model representing an authenticated user in the Habood app.
///
/// The `AppUser` struct provides a simplified abstraction of a Firebase `User`,
/// containing only essential identity properties for use across the app.
///
/// It conforms to both `Identifiable` and `Equatable` to support:
/// - SwiftUI bindings (using `.id`)
/// - Comparisons between user instances
///
/// - Author: Stephan Karatselios
/// - Contributor: Yunlong Chen (DocC documentation)
///
/// ## Overview
/// This model converts Firebase’s complex `User` object into a lightweight structure
/// that is easier to manage within SwiftUI and ViewModels.
///
/// The conversion is handled by the static method `fromFirebaseUser(_:)`.

struct AppUser: Identifiable, Equatable {
    let id: String
    let firstName: String
    let email: String
    
    init(id: String, firstName: String, email: String) {
        self.id = id
        self.firstName = firstName
        self.email = email
    }
    
    static func fromFirebaseUser(_ user: User) -> AppUser {
        let displayName = user.displayName ?? ""
        let first = displayName.split(separator: " ").first.map(String.init) ?? displayName
        return AppUser(id: user.uid, firstName: first, email: user.email ?? "")
    }
}
