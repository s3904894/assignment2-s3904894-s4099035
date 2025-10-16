//
//  MoodTrackerViewModelTests.swift
//  Habood
//
//  Created by Yunlong Chen on 2025/10/15.
//

import XCTest
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
@testable import Habood

/// Unit tests for verifying the core functionality of `MoodTrackerViewModel`.
///
/// These tests ensure that all mood tracking logic, intensity controls,
/// and Firebase saving actions behave as expected.
///
/// The file includes **five individual test cases** that cover:
/// - Mood selection logic
/// - Intensity value clamping
/// - Mood cycling
/// - Warning message when saving with no selection
/// - Successful save confirmation
///
/// All tests are written using **XCTest** and follow the
/// `@MainActor` annotation to support async SwiftUI ViewModel logic.
///
/// - Author: Yunlong Chen
@MainActor
final class MoodTrackerViewModelTests: XCTestCase {
    
    //  Test 1: Setting Mood
    
    /// Verifies that `setMood()` correctly updates the `selectedMood` property.
    ///
    /// Example:
    /// ```swift
    /// vm.setMood("😀 Happy")
    /// XCTAssertEqual(vm.selectedMood, "😀 Happy")
    /// ```
    func testSetMoodUpdatesSelectedMood() {
        let vm = MoodTrackerViewModel()
        vm.setMood("😀 Happy")
        XCTAssertEqual(vm.selectedMood, "😀 Happy", "setMood() should update selectedMood")
    }

    //  Test 2: Intensity Clamping
    
    /// Ensures that the intensity level stays within the valid range (1–5).
    ///
    /// Example:
    /// ```swift
    /// vm.setIntensity(10)  // → should clamp to 5
    /// vm.setIntensity(0)   // → should clamp to 1
    /// ```
    func testSetIntensityClampsRange() {
        let vm = MoodTrackerViewModel()
        vm.setIntensity(10)
        XCTAssertEqual(vm.intensity, 5, "Intensity should not exceed 5")
        vm.setIntensity(0)
        XCTAssertEqual(vm.intensity, 1, "Intensity should not go below 1")
    }

    //  Test 3: Mood Cycling
    
    /// Confirms that `nextMood()` correctly cycles to the first mood after the last one.
    ///
    /// Example:
    /// ```swift
    /// vm.setMood("😰 Anxious")
    /// vm.nextMood()
    /// XCTAssertEqual(vm.selectedMood, "😀 Happy")
    /// ```
    func testNextMoodCyclesThrough() {
        let vm = MoodTrackerViewModel()
        vm.setMood("😰 Anxious")
        vm.nextMood()
        XCTAssertEqual(vm.selectedMood, "😀 Happy", "nextMood should wrap around to first mood")
    }

    //  Test 4: Save Warning
    
    /// Ensures that saving without selecting a mood displays a warning message.
    ///
    /// Example:
    /// ```swift
    /// vm.saveMood()
    /// XCTAssertTrue(vm.saveMessage.contains("select"))
    /// ```
    func testSaveWithoutSelectionShowsWarning() {
        let vm = MoodTrackerViewModel()
        vm.saveMood()
        XCTAssertTrue(vm.saveMessage.contains("select"), "saveMood() should warn when no mood selected")
    }

    //  Test 5: Save Success
    
    /// Confirms that saving a valid mood updates the success message.
    ///
    /// This test uses an expectation to wait for the asynchronous
    /// save completion callback from `MoodService`.
    ///
    /// Example:
    /// ```swift
    /// vm.setMood("😀 Happy")
    /// vm.setIntensity(3)
    /// vm.saveMood()
    /// XCTAssertTrue(vm.saveMessage.contains("saved"))
    /// ```
    func testSaveMoodSetsSuccessMessage() {
        let vm = MoodTrackerViewModel()
        vm.setMood("😀 Happy")
        vm.setIntensity(3)
        
        let expectation = self.expectation(description: "Save mood")
        vm.saveMood()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(vm.saveMessage.contains("saved"), "saveMood() should confirm success")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}
