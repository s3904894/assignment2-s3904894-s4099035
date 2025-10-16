//
//  HabitService.swift
//  Habood
//
//  Created by Stephan Karatselios on 14/10/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

private struct HabitDoc: Codable{
    let habit: String
    let frequency: String
    let createdAt: Date
}

final class HabitService {
    private let db = Firestore.firestore()

     
    func addHabit(name: String, frequency: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print(" User not logged in. Cannot save habit.")
            completion(NSError(domain: "AuthError", code: 401,
                               userInfo: [NSLocalizedDescriptionKey: "Please sign in to save habits."]))
            return
        }
        let now = Date()
        let doc = HabitDoc(habit: name, frequency: frequency, createdAt: now)
        do {
            let wrapped = try FirebaseCrypto.shared.wrapDocument(doc, aad: "habits")
            var data: [String: Any] = wrapped
            data["userId"] = user.uid
            data["createdAt"] = Timestamp(date: now)
            db.collection("habits").addDocument(data: data) { error in
                if let error = error {
                    print(" Failed to save habit: \(error.localizedDescription)")
                    completion(error)
                } else {
                    print(" Habit '\(name)' saved successfully for user \(user.uid).")
                    completion(nil)
                }
            }
        } catch {
            completion(error)
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
                    completion(nil, error)
                    return
                }
                guard let snapshot = snapshot else {
                    completion([], nil)
                    return
                }
                let habits: [HabitEntryFirebase] = snapshot.documents.compactMap { doc in
                    let data = doc.data()
                    if let payload = data["payload"] as? [String: Any] {
                        do {
                            let hd: HabitDoc = try FirebaseCrypto.shared.decrypt(payload, as: HabitDoc.self, aad: "habits")
                            let created = (data["createdAt"] as? Timestamp)?.dateValue() ?? hd.createdAt
                            return HabitEntryFirebase(
                                id: doc.documentID,
                                userId: data["userId"] as? String ?? "",
                                habit: hd.habit,
                                frequency: hd.frequency,
                                createdAt: created
                            )
                        } catch {
                            print("Decrypt failed for \(doc.documentID): \(error.localizedDescription)")
                            return nil
                        }
                    }
                    if let habit = data["habit"] as? String,
                       let frequency = data["frequency"] as? String {
                        return HabitEntryFirebase(
                            id: doc.documentID,
                            userId: data["userId"] as? String ?? "",
                            habit: habit,
                            frequency: frequency,
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                        )
                    }
                    return nil
                }
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
