//
//  Untitled.swift
//  Habood
//
//  Created by Stephan Karatselios on 16/10/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/**
 Transport model representing a habit as stored in Firebase.

 ## Purpose
 Mirrors Firestore document fields for fetch and save operations.

 ## Mapping
 Convert to/from the in-app ``Habit`` model when needed.
 */

struct HabitEntryFirebase: Identifiable, Codable, Equatable {
    var id: String
    var userId: String
    var habit: String
    var frequency: String
    var createdAt: Date
}
