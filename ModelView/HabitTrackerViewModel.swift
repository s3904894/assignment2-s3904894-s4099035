//
//  HabitTrackerViewModel.swift
//  Habood
//
//  Created by Stephan Karatselios on 14/10/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// A ViewModel class responsible for managing habit tracking data and interactions in the Habood app.
///
/// The `HabitTrackerViewModel` connects the user interface (SwiftUI View)
/// with the underlying Firebase `HabitService`, allowing users to:
/// - Create and name new habits
/// - Select habit frequency (daily, weekly, etc.)
/// - Save habits to Firebase Firestore
///
/// - Author: Stephan Karatselios
/// - Contributor: Yunlong Chen (DocC documentation)
///
/// ## Overview
/// This ViewModel encapsulates user input logic and communicates with `HabitService`
/// to persist habits securely in Firebase.
/// It follows the **MVVM pattern**, allowing reactive SwiftUI updates via `@Published` properties.
///
/// ### Example:
/// ```swift
/// let viewModel = HabitTrackerViewModel()
/// viewModel.setHabit("Drink Water")
/// viewModel.setFrequency(0)  // Daily
/// viewModel.save { success in
///     print(success ? "Saved successfully!" : "Save failed.")
/// }
/// ```
@MainActor
final class HabitTrackerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The name of the habit entered by the user.
    ///
    /// Used for data binding with the text field in the SwiftUI view.
    @Published var habitName: String = ""
    
    /// The index of the selected frequency (e.g., 0 = Daily, 1 = Weekly).
    ///
    /// Bound to a Picker or segmented control in SwiftUI.
    @Published var frequencyIndex: Int = 0
    
    /// A message displayed after saving a habit (success or error).
    @Published var saveMessage: String? = nil
    
    /// Indicates whether a save operation is currently in progress.
    ///
    /// Used to control loading indicators in the UI.
    @Published var isSaving: Bool = false
    
    // MARK: - Frequency Options
    
    /// Available habit frequency options.
    ///
    /// Used to display a list of frequency choices to the user.
    let frequencyOptions = ["Daily", "Weekly", "Fortnightly", "Monthly"]
    
    /// Firebase service for saving and fetching habits.
    private let habitService = HabitService()
    
    /// Computed property that returns the currently selected frequency string.
    var selectedFrequency: String { frequencyOptions[frequencyIndex] }
    
    // MARK: - Setters
    
    /// Sets the habit name entered by the user.
    ///
    /// - Parameter name: The new habit name.
    ///
    /// - Example:
    /// ```swift
    /// viewModel.setHabit("Meditation")
    /// ```
    func setHabit(_ name: String) {
        habitName = name
    }
    
    /// Sets the selected frequency based on user interaction.
    ///
    /// - Parameter index: The selected index from `frequencyOptions`.
    ///
    /// - Example:
    /// ```swift
    /// viewModel.setFrequency(2)  // Fortnightly
    /// ```
    func setFrequency(_ index: Int) {
        guard index >= 0 && index < frequencyOptions.count else { return }
        frequencyIndex = index
    }
    
    // MARK: - Save Habit
    
    /// Saves the current habit to Firebase Firestore using `HabitService`.
    ///
    /// Validates the user input and passes data to the backend service.
    ///
    /// - Parameter completion: Closure returning `true` if successful, `false` otherwise.
    ///
    /// - Note:
    ///   The user must be logged in for this function to succeed.
    ///
    /// - Example:
    /// ```swift
    /// viewModel.save { success in
    ///     if success { print("Habit saved!") }
    /// }
    /// ```
    func save(completion: @escaping (Bool) -> Void) {
        let trimmed = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            saveMessage = "Enter a habit name."
            completion(false)
            return
        }

        // Indicate save in progress
        isSaving = true
        saveMessage = "Saving habit..."
        
        habitService.saveHabit(habit: trimmed, frequency: selectedFrequency) { [weak self] error in
            Task { @MainActor in
                self?.isSaving = false
                if let error = error {
                    self?.saveMessage = "Failed to save habit: \(error.localizedDescription)"
                    completion(false)
                } else {
                    self?.saveMessage = "Habit saved successfully!"
                    completion(true)
                }
            }
        }
    }
}
