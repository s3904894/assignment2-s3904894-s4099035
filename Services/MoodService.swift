//  Habood
//
//  Created by Yunlong Chen on 2025/10/10.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

//Protocol for dependency injection
protocol MoodServiceProtocol {
    /// Save a mood entry
    func saveMood(mood: String, intensity: Int, completion: @escaping (Error?) -> Void)

    /// Fetch mood entries (for history view)
    func fetchMoods(completion: @escaping ([MoodEntry]?, Error?) -> Void)
}

// Service Implementation
final class MoodService: MoodServiceProtocol {
    private let db = Firestore.firestore()

    // Save mood
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

    //  Fetch moods
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

