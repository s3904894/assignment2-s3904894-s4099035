//
//  FirebaseManager.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// A centralized manager responsible for initializing and providing access
/// to Firebase Authentication and Firestore services used across the Habood app.
///
/// The `FirebaseManager` class implements the **Singleton pattern**, meaning there is
/// only one shared instance (`FirebaseManager.shared`) used throughout the app.
///
/// This ensures consistent, thread-safe access to:
/// - `FirebaseAuth.Auth` for authentication (login / logout)
/// - `FirebaseFirestore.Firestore` for data storage and retrieval
///
/// - Author: Stephan Karatselios
/// - Contributor: Yunlong Chen (DocC documentation)
///
/// ## Overview
/// `FirebaseManager` acts as a global Firebase gateway.
/// It eliminates the need to reinitialize Firebase objects in multiple places.
///
/// ### Example:
/// ```swift
/// let userAuth = FirebaseManager.shared.auth
/// let database = FirebaseManager.shared.db
///
/// // Example usage:
/// database.collection("moods").getDocuments { snapshot, error in
///     if let docs = snapshot?.documents {
///         print("Loaded \(docs.count) mood records.")
///     }
/// }
/// ```
final class FirebaseManager {
    
    // MARK: - Shared Instance
    
    /// The single, shared instance of `FirebaseManager` used across the entire app.
    ///
    /// Use this shared property to access Firebase authentication or database references.
    ///
    /// ### Example:
    /// ```swift
    /// let manager = FirebaseManager.shared
    /// let firestore = manager.db
    /// ```
    static let shared = FirebaseManager()
    
    // MARK: - Initialization
    
    /// Private initializer to enforce the Singleton design pattern.
    ///
    /// This prevents other parts of the app from creating additional instances of `FirebaseManager`.
    private init() {}
    
    // MARK: - Firebase Services
    
    /// Firebase Authentication service for managing user login, logout, and account sessions.
    ///
    /// Provides access to functions like:
    /// - `Auth.auth().signIn(with:)`
    /// - `Auth.auth().currentUser`
    ///
    /// ### Example:
    /// ```swift
    /// let currentUser = FirebaseManager.shared.auth.currentUser
    /// ```
    let auth = Auth.auth()
    
    /// Firestore database service for reading and writing user data.
    ///
    /// Used for:
    /// - Storing mood and habit entries
    /// - Retrieving user-specific records
    /// - Listening to Firestore updates
    ///
    /// ### Example:
    /// ```swift
    /// let db = FirebaseManager.shared.db
    /// db.collection("habits").addDocument(data: ["habit": "Exercise"])
    /// ```
    let db = Firestore.firestore()
}
