//
//  MoodTrackerViewModel.swift
//  Habood
//
//  Created by Yunlong Chen on 2025/10/8.
//  Documented by Yunlong Chen

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// The ViewModel that manages all logic for mood tracking and Firebase synchronization.
///
/// This class stores the user's current mood and intensity,
/// handles gesture-based mood selection, and synchronizes mood data
/// with Firebase Firestore using the `MoodService`.
///
/// It is written using the **MVVM (Model-View-ViewModel)** pattern,
/// ensuring a clean separation between the UI (`MoodTrackerView`) and business logic.
///
/// - SeeAlso: `MoodService`, `MoodTrackerView`

@MainActor
final class MoodTrackerViewModel: ObservableObject {
    @Published var selectedMood: String = ""
    @Published var intensity: Int = 3 // range: 1–5
    @Published var saveMessage: String = ""
    
    private let moodService = MoodService()
    
    // Available moods with emojis
    let moods = ["😀 Happy", "😢 Sad", "😡 Angry", "😴 Tired", "😰 Anxious"]
    private var currentIndex = 0
    
    // MARK: - Mood Selection
    func setMood(_ mood: String) {
        selectedMood = mood
        if let index = moods.firstIndex(of: mood) {
            currentIndex = index
        }
    }
    
    // MARK: - Swipe gesture to change mood
    func nextMood() {
        currentIndex = (currentIndex + 1) % moods.count
        selectedMood = moods[currentIndex]
    }
    
    func previousMood() {
        currentIndex = (currentIndex - 1 + moods.count) % moods.count
        selectedMood = moods[currentIndex]
    }
    
    // MARK: - Adjust intensity
    func setIntensity(_ value: Int) {
        intensity = max(1, min(5, value))
    }
    
    // MARK: - Save mood to Firebase
    func saveMood() {
        guard !selectedMood.isEmpty else {
            saveMessage = " Please select a mood before saving."
            return
        }
        
        moodService.saveMood(mood: selectedMood, intensity: intensity) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.saveMessage = " Failed to save: \(error.localizedDescription)"
                } else {
                    self?.saveMessage = " Mood saved successfully!"
                }
            }
        }
    }
}
