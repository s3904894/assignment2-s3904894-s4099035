//
//  FireBaseManager.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    
    let auth = Auth.auth()
    let db = Firestore.firestore()
}
