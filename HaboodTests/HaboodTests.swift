//
//  HaboodTests.swift
//  HaboodTests
//
//  Created by Stephan Karatselios on 8/10/2025.
//  Created by yunlong chen on 16/10/2025.
//

import XCTest
@testable import Habood

/// A comprehensive test suite verifying MoodTrackerViewModel logic.
/// All tests are async-safe and compatible with Swift 6 concurrency model.
final class HaboodTests: XCTestCase {

    //  Test 1 – Mood selection updates correctly
    /// Verifies that calling `setMood()` updates the `selectedMood` property.
    func testSetMood() async throws {
        let viewModel = await MainActor.run { MoodTrackerViewModel() }
        await MainActor.run {
            viewModel.setMood("😀 Happy")
            XCTAssertEqual(viewModel.selectedMood, "😀 Happy",
                           "setMood() should correctly update selectedMood.")
        }
    }

    // Test 2 – Intensity stays within 1…5 range
    /// Verifies intensity clamping logic to avoid invalid values.
    func testIntensityRange() async throws {
        let viewModel = await MainActor.run { MoodTrackerViewModel() }
        await MainActor.run {
            viewModel.setIntensity(10)
            XCTAssertEqual(viewModel.intensity, 5,
                           "Intensity must cap at 5 when given 10.")
            viewModel.setIntensity(0)
            XCTAssertEqual(viewModel.intensity, 1,
                           "Intensity must floor at 1 when given 0.")
        }
    }

    //  Test 3 – nextMood() cycles correctly
    /// Ensures `nextMood()` loops back to the first mood after the last one.
    func testNextMoodCycle() async throws {
        let viewModel = await MainActor.run { MoodTrackerViewModel() }
        await MainActor.run {
            viewModel.setMood("😰 Anxious")
            viewModel.nextMood()
            XCTAssertEqual(viewModel.selectedMood, "😀 Happy",
                           "nextMood() should wrap around to first mood.")
        }
    }

    //  Test 4 – Saving without mood shows warning
    /// Checks that calling `saveMood()` without selection displays warning text.
    func testSaveWithoutSelection() async throws {
        let viewModel = await MainActor.run { MoodTrackerViewModel() }
        await MainActor.run {
            viewModel.saveMood()
            XCTAssertTrue(viewModel.saveMessage.contains("select"),
                          "saveMood() should warn when no mood selected.")
        }
    }

    // Test 5 – Saving mood returns success message
    /// Full async test verifying Firebase save flow updates `saveMessage`.
    func testSaveMoodSuccess() async throws {
        let viewModel = await MainActor.run { MoodTrackerViewModel() }

        // Configure mood and intensity
        await MainActor.run {
            viewModel.setMood("😊 Happy")
            viewModel.setIntensity(3)
        }

        // Create async expectation
        let expectation = XCTestExpectation(description: "Wait for saveMood completion")

        // Trigger save on MainActor
        await MainActor.run {
            viewModel.saveMood()
        }

        // Allow background completion before assertion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if viewModel.saveMessage.contains("saved") {
                expectation.fulfill()
            }
        }

        //  Swift 6 async-safe expectation handling
        await fulfillment(of: [expectation], timeout: 5.0)

        // Assert final outcome
        await MainActor.run {
            XCTAssertTrue(viewModel.saveMessage.contains("saved"),
                          "saveMood() should eventually set saveMessage to success.")
        }
    }
}


