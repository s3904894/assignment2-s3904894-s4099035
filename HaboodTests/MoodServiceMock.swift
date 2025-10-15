//
//  MoodServiceMock.swift
//  Habood
//
//  Created by yunlong chen on 2025/10/16.
//
import Foundation
@testable import Habood

/// Mock version of MoodService used for testing
final class MoodServiceMock: MoodServiceProtocol {
    var shouldFail = false
    var saveCalls: [(mood: String, intensity: Int)] = []

    // Simulating mood saving
    func saveMood(mood: String, intensity: Int, completion: @escaping (Error?) -> Void) {
        saveCalls.append((mood, intensity))
        if shouldFail {
            completion(NSError(domain: "TestMockError", code: 1,
                               userInfo: [NSLocalizedDescriptionKey: "Mock save failed"]))
        } else {
            completion(nil)
        }
    }

    // Simulate fetching mood data from Firebase
    func fetchMoods(completion: @escaping ([MoodEntry]?, Error?) -> Void) {
        if shouldFail {
            // Simulation failure
            completion(nil, NSError(domain: "TestMockError", code: 2,
                                    userInfo: [NSLocalizedDescriptionKey: "Mock fetch failed"]))
        } else {
            
            let dummyData = [
                MoodEntry(id: UUID().uuidString, mood: "😊 Happy", intensity: 4, createdAt: Date()),
                MoodEntry(id: UUID().uuidString, mood: "😢 Sad", intensity: 2, createdAt: Date().addingTimeInterval(-3600))
            ]
            completion(dummyData, nil)
        }
    }
}
