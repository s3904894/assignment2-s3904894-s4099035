//
//  MoodEntry.swift
//  Habood
//
//  Created by yunlong chen on 2025/10/4.
//
import Foundation
import SwiftData

/// Model for saving mood entries using SwiftData
@Model
final class MoodEntry {
    @Attribute(.unique) var id: String
    var mood: String        // e.g., "Happy", "Sad"
    var intensity: Int      // 1...5
    var createdAt: Date

    init(id: String = UUID().uuidString,
         mood: String,
         intensity: Int,
         createdAt: Date = .now) {
        self.id = id
        self.mood = mood
        self.intensity = intensity
        self.createdAt = createdAt
    }
}
