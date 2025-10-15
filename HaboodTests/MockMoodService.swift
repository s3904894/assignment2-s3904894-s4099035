//
//  MockMoodService.swift
//  Habood
//
//  Created by yunlongchen on 2025/10/16.
//
import Foundation
@testable import Habood

/// Mock version of MoodService used for testing without Firebase
final class MockMoodService: MoodServiceProtocol {
    var shouldFail = false
    var saveCalls: [(mood: String, intensity: Int)] = []

    func saveMood(mood: String, intensity: Int, completion: @escaping (Error?) -> Void) {
        saveCalls.append((mood, intensity))

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldFail {
                let error = NSError(domain: "TestError", code: 1,
                                    userInfo: [NSLocalizedDescriptionKey: "Mock save failed"])
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    func fetchMoods(completion: @escaping ([MoodEntry]?, Error?) -> Void) {
        if shouldFail {
            completion(nil, NSError(domain: "TestError", code: 2,
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
