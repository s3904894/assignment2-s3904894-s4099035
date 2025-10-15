//
//  MoodTrackerViewModel.swift
//  Habood
//
//  Created by Yunlong Chen on 2025/10/8.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

/// ViewModel for managing mood tracking and Firebase sync
@MainActor
final class MoodTrackerViewModel: ObservableObject {
    @Published var selectedMood: String = ""
    @Published var intensity: Int = 3 // range 1–5
    @Published var saveMessage: String = ""

    private let moodService: MoodServiceProtocol   // Using Protocol types

    //  Constructor: Injectable for Mock or real Firebase
    init(moodService: MoodServiceProtocol = MoodService()) {
        self.moodService = moodService
    }

    // Mood options
    let moods = ["😀 Happy", "😢 Sad", "😡 Angry", "😴 Tired", "😰 Anxious"]
    private var currentIndex = 0

    // Mood Selection
    func setMood(_ mood: String) {
        selectedMood = mood
        if let index = moods.firstIndex(of: mood) {
            currentIndex = index
        }
    }

    func nextMood() {
        currentIndex = (currentIndex + 1) % moods.count
        selectedMood = moods[currentIndex]
    }

    func previousMood() {
        currentIndex = (currentIndex - 1 + moods.count) % moods.count
        selectedMood = moods[currentIndex]
    }

    // Intensity
    func setIntensity(_ value: Int) {
        intensity = max(1, min(5, value))
    }

    // Save Mood
    func saveMood() {
        guard !selectedMood.isEmpty else {
            saveMessage = "Please select a mood before saving."
            return
        }

        // Temporary message
        saveMessage = "Saving mood..."

        // Save mood to Firebase or Mock
        moodService.saveMood(mood: selectedMood, intensity: intensity) { [weak self] error in
            Task { @MainActor in
                if let error = error {
                    self?.saveMessage = "Failed to save: \(error.localizedDescription)"
                } else {
                    self?.saveMessage = "Mood saved successfully!"
                }
            }
        }
    }
}
