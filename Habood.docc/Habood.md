# Habood App Documentation

@Metadata {
    @PageKind(article)
    @DisplayName("Habood App Documentation")
}

Welcome to the official documentation for **Habood**, an iOS wellbeing application developed as part of the *iPSE Assignment 2 project*.  
This documentation is generated using Xcode’s **DocC** system and provides a detailed overview of the project’s architecture, components, and functionality.

---

## Overview

**Habood** is a wellbeing-focused mobile app that helps users build healthy habits and track their moods through an elegant, minimalistic interface.  
The app integrates **SwiftUI**, **UIKit**, **Firebase**, and **SwiftData** to provide seamless synchronization and a modern Apple-style user experience.

### Objectives
- Combine **SwiftUI** and **UIKit** components in a single cohesive app.  
- Implement **Firebase Firestore** for secure cloud data storage.  
- Follow the **MVVM (Model-View-ViewModel)** design pattern.  
- Include at least **five automated unit tests** for core features.  
- Deliver **comprehensive developer documentation** using **Apple DocC**.

---

## Architecture

Habood follows a clean **MVVM** (Model-View-ViewModel) architecture to ensure maintainability and scalability.

| Layer | Components | Description |
|-------|-------------|-------------|
| **Model** | `MoodEntry`, `SettingsItem` | Defines data entities stored with SwiftData. |
| **ViewModel** | `MoodTrackerViewModel`, `HabitTrackerViewModel` | Manages app logic, state updates, and Firebase communication. |
| **View** | `MoodTrackerView`, `HabitTrackerView`, `MoodHistoryView` | Presents data and interacts with the user using SwiftUI. |
| **Services** | `MoodService`, `MockMoodService` | Handles Firestore operations and mock testing. |
| **UIKit Integration** | `ShareSheet` | Demonstrates UIKit interoperability within SwiftUI. |

This modular design allows independent testing and clear separation of concerns between UI, logic, and data.

---

## Core Features

### Mood Tracker

The **Mood Tracker** allows users to record their emotional state with just a few taps.  
Each mood entry includes:
- Mood name (e.g., “ Happy”)  
- Intensity level (1–5)  
- Timestamp  
- User ID linked through Firebase Authentication  

#### Interactions
- **Swipe left / right:** Change mood  
- **Swipe up / down:** Adjust intensity  
- **Tap “Save Mood”:** Save mood entry to Firestore  
- **Tap “View Mood History”:** Review all saved moods  

---

### Widget Integration (HaboodWidget)

The **Habood Widget Extension** enables users to view their latest saved mood directly on the iOS Home Screen.  
It integrates **WidgetKit** and **Firebase Firestore**, allowing real-time synchronization of mood entries.

#### Implementation Details
- The widget reads the user’s `UID` from a shared **App Group** container (`group.com.habood.shared`).
- Uses **FirebaseApp.configure()** safely within the extension context via `FirebaseWidgetManager`.
- Fetches the most recent mood record (`mood`, `intensity`, `createdAt`) from Firestore.
- Automatically updates every 30 minutes or when triggered via:
  ```swift
  WidgetCenter.shared.reloadAllTimelines()

Technical Highlights
    •    Uses TimelineProvider for dynamic mood refresh.
    •    Displays a compact Mood Summary Card:
    •    Mood emoji and description (e.g.,  Happy)
    •    Intensity indicator (1–5)
    •    “Sign in to view moods” fallback if user is not logged in.
    •    Ensures lightweight performance by caching Firebase configuration safely on the main thread.

Example Code

struct MoodEntry: TimelineEntry {
    let date: Date
    let mood: String
    let intensity: Int
}

struct MoodProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodEntry>) -> Void) {
        FirebaseWidgetManager.shared.configureFirebaseIfNeeded()
        // Fetch latest mood from Firestore
    }
}

Result: The widget seamlessly mirrors the user’s current emotional state from Firestore without requiring manual refresh.

⸻

Mood Tracker (Redesigned Apple-Style UI)

The Mood Tracker View has been redesigned to align with Apple’s Human Interface Guidelines (HIG).
It now provides a clean, minimalist, and native iOS look consistent with the Settings and Health apps.

UI Enhancements
    •    Replaced colored backgrounds with system adaptive tones (Color(.systemGroupedBackground)).
    •    Introduced rounded white cards for mood and intensity selection.
    •    Unified button styles for “Save Mood”, “Share My Mood”, and “View Mood History” with system typography (.title3, .semibold, .systemBlue).
    •    Added placeholder guidance:

Picker("Select your mood", selection: $selectedMood)

    •    Shows a default label “Select your mood”.
    •    Automatically updates after selection (e.g.,  Sad →  Happy).

Visual Structure

Section    Description
Mood Picker    Allows user to select current emotion with emoji.
Intensity Slider    Adjustable level indicator (1–5).
Save Mood Button    Saves data to Firestore with success animation.
Share / History Buttons    Integrates with UIKit ShareSheet and local mood history.

Design Philosophy

“Simplicity and emotional calmness” — The UI aims to reduce visual noise while maintaining clarity.
Users can focus on reflection rather than interface complexity.

⸻

Habit Tracker

The Habit Tracker enables users to set, monitor, and sustain daily goals.

Key Functions
    •    Create, edit, and delete habits
    •    Mark habits as completed
    •    Track progress streaks
    •    Save data locally via SwiftData for offline use

⸻

Firebase and SwiftData Synchronization

Habood synchronizes seamlessly between local and cloud databases:
    •    Cloud Sync: Firestore stores all mood and habit entries.
    •    Offline Cache: SwiftData provides local storage when offline.
    •    Authentication: Google Sign-In using FirebaseAuth.
    •    Automatic Merge: Data merges when reconnected.

This ensures consistent user experience even without network connectivity.

⸻

UIKit Integration

Habood integrates UIKit functionality through a custom ShareSheet component.

import UIKit
import SwiftUI

/// A UIKit-based share sheet integrated into the SwiftUI app.
///
/// This demonstrates interoperability between SwiftUI and UIKit.
public struct ShareSheet: UIViewControllerRepresentable {
    public var activityItems: [Any]
    
    public init(activityItems: [Any]) {
        self.activityItems = activityItems
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


⸻

Unit Tests

Habood includes five automated unit tests to verify the correctness of app logic and data flow.

Test    Description
testSetMood()    Ensures mood selection updates correctly.
testIntensityRange()    Verifies mood intensity remains between 1–5.
testNextMoodCycle()    Checks correct mood cycling order.
testSaveWithoutSelection()    Displays warning if mood not selected.
testSaveMoodSuccess()    Confirms that saving triggers success message.

All tests have successfully passed in Xcode’s XCTest environment.

⸻

Contributors

Name    Student ID    Responsibilities
Yunlong Chen    s4099035    Mood Tracker, Firebase Integration, Widget Development, Unit Tests, DocC Documentation
Stephan Karatselios    s3904894    Habit Tracker, Authentication, UIKit Integration, UITests


⸻

License

This project was created for academic purposes as part of the RMIT iPSE course.
All code and documentation are intended for educational use only.

© 2025 RMIT University — School of Computing Technologies
All rights reserved. Redistribution or commercial use is prohibited.

⸻

Metadata

Last Updated: October 2025
Generated by: Apple DocC (Xcode 16)
Maintainer: Yunlong Chen (s4099035)

---
