//
//  Untitled.swift
//  Habood
//
//  Created by Stephan Karatselios on 16/10/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct HabitEntryFirebase: Identifiable, Codable, Equatable {
    var id: String
    var userId: String
    var habit: String
    var frequency: String
    var createdAt: Date
}
