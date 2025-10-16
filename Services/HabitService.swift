//
//  HabitService.swift
//  Habood
//
//  Created by Stephan Karatselios on 14/10/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class HabitService {
    private let db = Firestore.firestore()

     
    func addHabit(name: String, frequency: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print(" User not logged in. Cannot save habit.")
            completion(NSError(domain: "AuthError", code: 401,
                               userInfo: [NSLocalizedDescriptionKey: "Please sign in to save habits."]))
            return
        }
        
        let data: [String: Any] = [
            "userId": user.uid,
            "habit": name,
            "frequency": frequency,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("habits").addDocument(data: data) { error in
            if let error = error {
                print(" Failed to save habit: \(error.localizedDescription)")
                completion(error)
            } else {
                print(" Habit '\(name)' saved successfully for user \(user.uid).")
                completion(nil)
            }
        }
    }

    func fetchHabits(completion: @escaping ([HabitEntryFirebase]?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print(" User not logged in. Cannot fetch habits.")
            completion([], NSError(domain: "AuthError", code: 401,
                                   userInfo: [NSLocalizedDescriptionKey: "Please sign in to view habits."]))
            return
        }

        db.collection("habits")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" Error fetching habits: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }

                let habits: [HabitEntryFirebase] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let habit = data["habit"] as? String,
                        let frequency = data["frequency"] as? String
                    else {
                        return nil
                    }
                    return HabitEntryFirebase(
                        id: doc.documentID,
                        userId: data["userId"] as? String ?? "",
                        habit: habit,
                        frequency: frequency,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []

                print(" Loaded \(habits.count) habit entries for user \(user.uid).")
                completion(habits, nil)
            }
    }

    func deleteHabit(id: String, completion: @escaping (Error?) -> Void) {
        db.collection("habits").document(id).delete(completion: completion)
    }
}


struct HabitEntryFirebase: Identifiable, Codable, Equatable {
    var id: String
    var userId: String
    var habit: String
    var frequency: String
    var createdAt: Date
}
