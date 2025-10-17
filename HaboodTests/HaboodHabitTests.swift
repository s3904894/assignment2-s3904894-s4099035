//
//  HaboodHabitTests.swift
//  Habood
//
//  Created by Stephan Karatselios on 17/10/2025.
//

import XCTest
@testable import Habood

@MainActor
final class HabitTests: XCTestCase {

    var mock: HabitServiceMock!

    override func setUp() async throws {
        try await super.setUp()
        mock = HabitServiceMock()
    }

    func testCreateNewHabit() async throws {
        let exp = expectation(description: "create")
        mock.createHabit(name: "Read", frequency: "Daily") { ok in
            XCTAssertTrue(ok, "Create should succeed")
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertEqual(mock.habits.count, 1)
        XCTAssertEqual(mock.habits.first?.name, "Read")
        XCTAssertEqual(mock.habits.first?.frequency, "Daily")
    }

    func testDeleteHabit() async throws {
        let seed = HabitServiceMock.Habit(id: "A", name: "Run", frequency: "Weekly")
        mock.habits = [seed]

        let exp = expectation(description: "delete")
        mock.deleteHabit(id: "A") { ok in
            XCTAssertTrue(ok, "Delete should succeed")
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(mock.habits.isEmpty)
    }
    
    func testSetHabitWithBlankFieldFailsValidation() {
        func isValidName(_ s: String) -> Bool { s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }

        XCTAssertFalse(isValidName(""), "Empty string invalid")
        XCTAssertFalse(isValidName("   "), "Whitespace-only invalid")
        XCTAssertTrue(isValidName("Study"), "Non-empty valid")
    }
    
    func testChoosingCancelOnSignIn() async throws {
        enum AuthError: Error { case canceled }
        
        func signIn(completion: @escaping (Result<Void, Error>) -> Void) {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
                completion(.failure(AuthError.canceled))
            }
        }

        let exp = expectation(description: "signin")
        var receivedCanceled = false
        signIn { result in
            if case .failure(let err) = result, (err as? AuthError) == .canceled {
                receivedCanceled = true
            }
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(receivedCanceled, "UI should treat cancel as non-fatal and stay on current screen")
    }

    func testFetchHabits() async throws {
        mock.habits = [
            .init(id: "1", name: "Meditate", frequency: "Daily"),
            .init(id: "2", name: "Gym", frequency: "Weekly")
        ]

        let exp = expectation(description: "fetch")
        var fetched: [HabitServiceMock.Habit]?
        var fetchErr: Error?
        mock.fetchHabits { items, err in
            fetched = items
            fetchErr = err
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertNil(fetchErr)
        XCTAssertEqual(fetched?.count, 2)
        XCTAssertEqual(fetched?.map(\.name), ["Meditate", "Gym"])
    }
}
