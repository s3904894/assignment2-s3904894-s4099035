//
//  AppUser.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//  Documented by Yunlong Chen on 16/10/2025.
//

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
///
/// ### Example:
/// ```swift
/// if let user = Auth.auth().currentUser {
///     let appUser = AppUser.fromFirebaseUser(user)
///     print("Welcome, \(appUser.firstName)")
/// }
/// ```
struct AppUser: Identifiable, Equatable {
    
    // MARK: - Properties
    
    /// The unique user identifier (Firebase UID).
    let id: String
    
    /// The user's first name extracted from their display name.
    ///
    /// If the Firebase display name contains multiple words, only the first one is used.
    let firstName: String
    
    /// The user's registered email address.
    let email: String
    
    // MARK: - Initializer
    
    /// Creates a new `AppUser` instance with provided details.
    ///
    /// - Parameters:
    ///   - id: Firebase UID.
    ///   - firstName: The user's first name.
    ///   - email: The user's email address.
    ///
    /// - Example:
    /// ```swift
    /// let user = AppUser(id: "abc123", firstName: "Yunlong", email: "yunlong@example.com")
    /// ```
    init(id: String, firstName: String, email: String) {
        self.id = id
        self.firstName = firstName
        self.email = email
    }
    
    // MARK: - Firebase Conversion
    
    /// Converts a Firebase `User` object into an `AppUser` model.
    ///
    /// This helper method extracts the `uid`, `displayName`, and `email`
    /// fields from Firebase’s authentication user object.
    ///
    /// - Parameter user: The Firebase `User` instance to convert.
    /// - Returns: A simplified `AppUser` instance.
    ///
    /// - Example:
    /// ```swift
    /// let firebaseUser = Auth.auth().currentUser
    /// let appUser = AppUser.fromFirebaseUser(firebaseUser)
    /// ```
    static func fromFirebaseUser(_ user: User) -> AppUser {
        let displayName = user.displayName ?? ""
        let first = displayName.split(separator: " ").first.map(String.init) ?? displayName
        return AppUser(id: user.uid, firstName: first, email: user.email ?? "")
    }
}
