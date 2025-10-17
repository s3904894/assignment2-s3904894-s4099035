//
//  FireBaseManager.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//  Documented by Yunlong Chen

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

final class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    
    let auth = Auth.auth()
    let db = Firestore.firestore()
}
