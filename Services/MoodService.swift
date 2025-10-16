//
//  MoodService.swift
//  Habood
//
//  Created by Yunlong Chen on 2025/10/10.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

//  Protocol Definition

/// A protocol that defines the methods required for any mood data service.
///
/// This protocol supports **dependency injection**, allowing you to use either
/// the real Firebase-backed `MoodService` or a `MockMoodService` for testing.
/// - Author: Yunlong Chen
protocol MoodServiceProtocol {
    /// Saves a new mood entry.
    /// - Parameters:
    ///   - mood: The selected mood as a `String` (e.g. `"😊 Happy"`).
    ///   - intensity: The mood intensity level, ranging from 1 to 5.
    ///   - completion: A closure called when saving finishes, returning an optional error.
    func saveMood(mood: String, intensity: Int, completion: @escaping (Error?) -> Void)

    /// Fetches all stored mood entries for the current user.
    /// - Parameter completion: Returns an array of `MoodEntry` objects or an error.
    func fetchMoods(completion: @escaping ([MoodEntry]?, Error?) -> Void)
}

//  Firebase Service Implementation

/// A service responsible for managing mood data using **Firebase Firestore**.
///
/// This class is responsible for saving and retrieving moods from Firestore.
/// It requires the user to be signed in via Firebase Authentication.
///
/// **Features:**
/// - Saves mood data including mood, intensity, timestamp, and user ID
/// - Fetches user-specific mood history ordered by creation date
/// - Prints console logs for all read/write operations
///
/// - SeeAlso: `MoodServiceProtocol`
/// - Author: Yunlong Chen
final class MoodService: MoodServiceProtocol {
    private let db = Firestore.firestore()

    // Save Mood

    /// Saves a mood entry to Firestore for the authenticated user.
    ///
    /// If the user is not logged in, the function will return an authentication error.
    ///
    /// Example:
    /// ```swift
    /// moodService.saveMood(mood: "😊 Happy", intensity: 4) { error in
    ///     if let error = error {
    ///         print("Save failed:", error.localizedDescription)
    ///     } else {
    ///         print("Mood saved successfully!")
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///   - mood: The name of the selected mood (e.g., `"😊 Happy"`).
    ///   - intensity: The mood intensity value (1–5 scale).
    ///   - completion: A closure returning an optional `Error` after saving.
    func saveMood(mood: String, intensity: Int, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in. Cannot save mood.")
            completion(NSError(domain: "AuthError", code: 401,
                               userInfo: [NSLocalizedDescriptionKey: "Please sign in to save moods."]))
            return
        }

        let data: [String: Any] = [
            "userId": user.uid,
            "mood": mood,
            "intensity": intensity,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("moods").addDocument(data: data) { error in
            if let error = error {
                print("Failed to save mood: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Mood '\(mood)' saved successfully for user \(user.uid).")
                completion(nil)
            }
        }
    }

    // Fetch Moods

    /// Fetches all mood entries from Firestore for the current logged-in user.
    ///
    /// This function retrieves all mood entries associated with the user's Firebase UID,
    /// ordered by creation date in descending order.
    ///
    /// Example:
    /// ```swift
    /// moodService.fetchMoods { moods, error in
    ///     if let moods = moods {
    ///         print("Fetched \(moods.count) entries.")
    ///     }
    /// }
    /// ```
    /// - Parameter completion: A closure returning a list of `MoodEntry` objects or an `Error`.
    func fetchMoods(completion: @escaping ([MoodEntry]?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in. Cannot fetch moods.")
            completion(nil, NSError(domain: "AuthError", code: 401,
                                    userInfo: [NSLocalizedDescriptionKey: "Please sign in to view moods."]))
            return
        }

        db.collection("moods")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching moods: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }

                let moods = snapshot?.documents.compactMap { doc -> MoodEntry? in
                    let data = doc.data()
                    return MoodEntry(
                        id: doc.documentID,
                        mood: data["mood"] as? String ?? "Unknown",
                        intensity: data["intensity"] as? Int ?? 0,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []

                print("Loaded \(moods.count) mood entries for user \(user.uid).")
                completion(moods, nil)
            }
    }
}
