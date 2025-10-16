//
//  MoodTrackerViewModel.swift
//  Habood
//
//  Created by Yunlong Chen on 2025/10/8.
//

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
/// - Author: Yunlong Chen
@MainActor
final class MoodTrackerViewModel: ObservableObject {
    
    // Published Properties
    
    /// The currently selected mood string, e.g. `"😀 Happy"` or `"😢 Sad"`.
    @Published var selectedMood: String = ""
    
    /// The intensity level for the selected mood (1–5 range). Defaults to 3.
    @Published var intensity: Int = 3
    
    /// A feedback message shown to the user after attempting to save a mood.
    /// It indicates whether the save was successful or failed.
    @Published var saveMessage: String = ""
    
    /// The data service used for saving and retrieving moods.
    /// Supports **dependency injection** for testing (e.g., `MockMoodService`).
    private let moodService: MoodServiceProtocol
    
    // Initialization
    
    /// Initializes the ViewModel with a given `MoodServiceProtocol` instance.
    ///
    /// This allows switching between the real Firebase service and a mock service
    /// for testing without modifying the main logic.
    /// - Parameter moodService: A type conforming to `MoodServiceProtocol`. Defaults to `MoodService()`.
    init(moodService: MoodServiceProtocol = MoodService()) {
        self.moodService = moodService
    }
    
    // Mood Options
    
    /// A predefined list of available moods shown to the user.
    let moods = ["😀 Happy", "😢 Sad", "😡 Angry", "😴 Tired", "😰 Anxious"]
    
    /// The current index of the selected mood within the list.
    private var currentIndex = 0
    
    //  Mood Selection Logic
    
    /// Updates the selected mood and synchronizes the current index.
    /// - Parameter mood: The chosen mood string from the list.
    func setMood(_ mood: String) {
        selectedMood = mood
        if let index = moods.firstIndex(of: mood) {
            currentIndex = index
        }
    }
    
    /// Switches to the **next mood** in the list (circular navigation).
    ///
    /// Example:
    /// ```swift
    /// viewModel.nextMood()
    /// ```
    func nextMood() {
        currentIndex = (currentIndex + 1) % moods.count
        selectedMood = moods[currentIndex]
    }
    
    /// Switches to the **previous mood** in the list (circular navigation).
    ///
    /// Example:
    /// ```swift
    /// viewModel.previousMood()
    /// ```
    func previousMood() {
        currentIndex = (currentIndex - 1 + moods.count) % moods.count
        selectedMood = moods[currentIndex]
    }
    
    //  Intensity Control
    
    /// Updates the mood intensity value while keeping it within the valid range (1–5).
    ///
    /// Example:
    /// ```swift
    /// viewModel.setIntensity(4)
    /// ```
    /// - Parameter value: The new intensity value provided by the user.
    func setIntensity(_ value: Int) {
        intensity = max(1, min(5, value))
    }
    
    //  Firebase Integration
    
    /// Saves the current mood and intensity to Firebase Firestore.
    ///
    /// This function uses the injected `MoodService` to store mood data in the cloud.
    /// If no mood has been selected, a warning message is displayed instead.
    ///
    /// Example:
    /// ```swift
    /// viewModel.setMood("😀 Happy")
    /// viewModel.setIntensity(3)
    /// viewModel.saveMood()
    /// ```
    func saveMood() {
        guard !selectedMood.isEmpty else {
            saveMessage = "Please select a mood before saving."
            return
        }

        // Temporary loading message
        saveMessage = "Saving mood..."

        // Save mood using the MoodService
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
