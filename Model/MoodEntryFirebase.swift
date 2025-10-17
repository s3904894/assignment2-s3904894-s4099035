//
//  MoodEntryFirebase.swift
//  Habood
//
//  Created by Stephan Karatselios on 17/10/2025.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

struct MoodEntryFirebase: Identifiable {
    let id: String
    let mood: String
    let intensity: Int
    let createdAt: Date
}
