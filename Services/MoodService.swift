//  Habood
//
//  Created by Yunlong Chen on 2025/10/10.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Service for managing mood data in Firebase Firestore
class MoodService {
    private let db = Firestore.firestore()

    /// Save a mood entry to Firestore (only if user is logged in)
    func saveMood(mood: String, intensity: Int, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print(" User not logged in. Cannot save mood.")
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Please sign in to save moods."]))
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
                print(" Failed to save mood: \(error.localizedDescription)")
                completion(error)
            } else {
                print(" Mood '\(mood)' saved successfully for user \(user.uid).")
                completion(nil)
            }
        }
    }

    /// Fetch all mood entries for the current user (login required)
    func fetchMoods(completion: @escaping ([MoodEntryFirebase]?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print(" User not logged in. Cannot fetch moods.")
            completion([], NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Please sign in to view moods."]))
            return
        }

        db.collection("moods")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" Error fetching moods: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }

                let moods = snapshot?.documents.compactMap { doc -> MoodEntryFirebase? in
                    let data = doc.data()
                    return MoodEntryFirebase(
                        id: doc.documentID,
                        mood: data["mood"] as? String ?? "Unknown",
                        intensity: data["intensity"] as? Int ?? 0,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []

                print(" Loaded \(moods.count) mood entries for user \(user.uid).")
                completion(moods, nil)
            }
    }
}

/// Firebase mood model (for reading Firestore data)
struct MoodEntryFirebase: Identifiable {
    let id: String
    let mood: String
    let intensity: Int
    let createdAt: Date
}
