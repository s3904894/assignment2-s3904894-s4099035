//
//  MoodTrackerViewModelTests.swift
//  Habood
//
//  Created by yunlong chen on 2025/10/15.
//
import XCTest
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
@testable import Habood

//  Unit Tests for MoodTrackerViewModel
@MainActor
final class MoodTrackerViewModelTests: XCTestCase {
    
    //  Test 1 - Setting mood
    func testSetMoodUpdatesSelectedMood() {
        let vm = MoodTrackerViewModel()
        vm.setMood("😀 Happy")
        XCTAssertEqual(vm.selectedMood, "😀 Happy", "setMood() should update selectedMood")
    }

    //  Test 2 - Intensity stays within 1...5
    func testSetIntensityClampsRange() {
        let vm = MoodTrackerViewModel()
        vm.setIntensity(10)
        XCTAssertEqual(vm.intensity, 5, "Intensity should not exceed 5")
        vm.setIntensity(0)
        XCTAssertEqual(vm.intensity, 1, "Intensity should not go below 1")
    }

    //  Test 3 - nextMood cycles through correctly
    func testNextMoodCyclesThrough() {
        let vm = MoodTrackerViewModel()
        vm.setMood("😰 Anxious")
        vm.nextMood()
        XCTAssertEqual(vm.selectedMood, "😀 Happy", "nextMood should wrap around to first mood")
    }

    //  Test 4 - Save mood without selection shows warning
    func testSaveWithoutSelectionShowsWarning() {
        let vm = MoodTrackerViewModel()
        vm.saveMood()
        XCTAssertTrue(vm.saveMessage.contains("select"), "saveMood() should warn when no mood selected")
    }

    //  Test 5 - Save mood success
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
