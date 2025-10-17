//
//  HabitServiceMock.swift
//  Habood
//
//  Created by Stephan Karatselios on 17/10/2025.
//

import Foundation
@testable import Habood

final class HabitServiceMock {

    struct Habit: Equatable, Identifiable {
        let id: String
        var name: String
        var frequency: String
    }

    var habits: [Habit] = []
    var nextCreateShouldFail = false
    var nextDeleteShouldFail = false
    var nextFetchError: Error?

    private let delay: TimeInterval = 0.01

    func fetchHabits(completion: @escaping ([Habit]?, Error?) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [self] in
            completion(nextFetchError == nil ? habits : nil, nextFetchError)
            nextFetchError = nil
        }
    }

    func createHabit(name: String, frequency: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [self] in
            if nextCreateShouldFail {
                nextCreateShouldFail = false
                completion(false)
                return
            }
            let h = Habit(id: UUID().uuidString, name: name, frequency: frequency)
            habits.append(h)
            completion(true)
        }
    }

    func deleteHabit(id: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [self] in
            if nextDeleteShouldFail {
                nextDeleteShouldFail = false
                completion(false)
                return
            }
            habits.removeAll { $0.id == id }
            completion(true)
        }
    }
}
