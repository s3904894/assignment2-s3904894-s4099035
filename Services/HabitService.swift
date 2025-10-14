//
//  HabitService.swift
//  Habood
//
//  Created by Stephan Karatselios on 14/10/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Service for managing mood data in Firebase Firestore
class HabitService {
    private let db = Firestore.firestore()

    /// Save a mood entry to Firestore (only if user is logged in)
    func saveHabit(habit: String, frequency: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print(" User not logged in. Cannot save Habit.")
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Please sign in to save moods."]))
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
                print(" Failed to save habit: \(error.localizedDescription)")
                completion(error)
            } else {
                print(" Habit '\(habit)' saved successfully for user \(user.uid).")
                completion(nil)
            }
        }
    }

    /// Fetch all mood entries for the current user (login required)
    func fetchHabits(completion: @escaping ([HabitEntryFirebase]?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print(" User not logged in. Cannot fetch habits.")
            completion([], NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Please sign in to view habits."]))
            return
        }

        db.collection("habits")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" Error fetching moods: \(error.localizedDescription)")
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

                print(" Loaded \(habits.count) mood entries for user \(user.uid).")
                completion(habits, nil)
            }
    }
}

/// Firebase mood model (for reading Firestore data)
struct HabitEntryFirebase: Identifiable {
    let id: String
    let habit: String
    let frequency: String
    let createdAt: Date
}
