//
//  HabitService.swift
//  Habood
//
//  Created by Stephan Karatselios on 14/10/2025.
//  
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// A service class responsible for managing **Habit Tracker** data in Firebase Firestore.
///
/// The `HabitService` provides methods to:
/// - Save new user habits (habit name + frequency)
/// - Fetch existing habits associated with the current Firebase user
///
/// This class mirrors the design of `MoodService`, ensuring consistent integration with
/// Firebase Authentication and Firestore database.
///
/// - Author: Stephan Karatselios
/// - Contributor: Yunlong Chen (DocC documentation)
class HabitService {
    /// Reference to the Firestore database.
    private let db = Firestore.firestore()

    // MARK: - Save Habit

    /// Saves a new habit entry to Firestore for the currently authenticated user.
    ///
    /// The saved document includes:
    /// - `userId`: the current user's Firebase UID
    /// - `habit`: the name of the habit (e.g. “Drink Water”)
    /// - `frequency`: how often the habit is performed (e.g. “Daily”, “Weekly”)
    /// - `createdAt`: timestamp of when it was saved
    ///
    /// - Parameters:
    ///   - habit: The name of the habit to store.
    ///   - frequency: The user-defined frequency (e.g., “Daily”, “Weekly”).
    ///   - completion: A closure returning an optional `Error` if saving fails.
    ///
    /// - Important:
    ///   This method requires the user to be authenticated via Firebase Authentication.
    ///   If the user is not logged in, an `AuthError` will be returned.
    ///
    /// - Example:
    /// ```swift
    /// habitService.saveHabit(habit: "Meditation", frequency: "Daily") { error in
    ///     if let error = error {
    ///         print("Save failed: \(error.localizedDescription)")
    ///     }
    /// }
    /// ```
    func saveHabit(habit: String, frequency: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in. Cannot save habit.")
            completion(NSError(domain: "AuthError", code: 401,
                               userInfo: [NSLocalizedDescriptionKey: "Please sign in to save habits."]))
            return
        }

        let data: [String: Any] = [
            "userId": user.uid,
            "habit": habit,
            "frequency": frequency,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("habits").addDocument(data: data) { error in
            if let error = error {
                print("Failed to save habit: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Habit '\(habit)' saved successfully for user \(user.uid).")
                completion(nil)
            }
        }
    }

    // MARK: - Fetch Habits

    /// Fetches all habit entries for the currently authenticated Firebase user.
    ///
    /// The returned list is ordered by `createdAt` (most recent first).
    ///
    /// - Parameters:
    ///   - completion: Closure returning a list of `HabitEntryFirebase` objects or an `Error`.
    ///
    /// - Note:
    ///   The user must be signed in before calling this method.
    ///
    /// - Example:
    /// ```swift
    /// habitService.fetchHabits { habits, error in
    ///     if let habits = habits {
    ///         print("Loaded \(habits.count) habits.")
    ///     }
    /// }
    /// ```
    func fetchHabits(completion: @escaping ([HabitEntryFirebase]?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in. Cannot fetch habits.")
            completion([], NSError(domain: "AuthError", code: 401,
                                   userInfo: [NSLocalizedDescriptionKey: "Please sign in to view habits."]))
            return
        }

        db.collection("habits")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching habits: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }

                let habits = snapshot?.documents.compactMap { doc -> HabitEntryFirebase? in
                    let data = doc.data()
                    return HabitEntryFirebase(
                        id: doc.documentID,
                        habit: data["habit"] as? String ?? "Unknown",
                        frequency: data["frequency"] as? String ?? "Unknown",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []

                print("Loaded \(habits.count) habit entries for user \(user.uid).")
                completion(habits, nil)
            }
    }
}

// MARK: - Firebase Data Model

/// A struct that represents a single habit record retrieved from Firestore.
///
/// Used for reading user habits from Firebase in a structured format.
///
/// - Example:
/// ```swift
/// HabitEntryFirebase(id: "123", habit: "Run 5km", frequency: "Daily", createdAt: Date())
/// ```
///
/// - Author: Stephan Karatselios
struct HabitEntryFirebase: Identifiable {
    /// Firestore document ID
    let id: String
    /// Habit name (e.g., "Drink Water")
    let habit: String
    /// Frequency (e.g., "Daily", "Weekly")
    let frequency: String
    /// Creation timestamp
    let createdAt: Date
}
