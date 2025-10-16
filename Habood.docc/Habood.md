# Habood App Documentation

@Metadata {
    @PageKind(article)
    @DisplayName("Habood App Documentation")
}

Welcome to the official documentation for **Habood**, an iOS application developed as part of the iPSE Assignment 2 project.  
This documentation is generated using Xcode’s **DocC** system and provides a complete overview of the project’s architecture, components, and functionality.

---

## Overview

**Habood** is a wellbeing-focused mobile app that helps users build positive habits and track their moods through an intuitive, gesture-based interface.  
The app integrates **SwiftUI**, **UIKit**, **Firebase**, and **SwiftData** to provide seamless data synchronization and a modern user experience.

### Objectives
- Combine **SwiftUI** and **UIKit** in one app.  
- Implement **Firebase Firestore** for cloud storage.  
- Follow the **MVVM (Model-View-ViewModel)** design pattern.  
- Include **five automated unit tests**.  
- Provide **exhaustive documentation** using Apple **DocC**.

---

## Architecture

Habood follows a clean **MVVM** structure:

- **Model**: `MoodEntry`, `SettingsItem`  
  Defines data entities stored using SwiftData.

- **ViewModel**: `MoodTrackerViewModel`, `HabitTrackerViewModel`  
  Handles logic, state management, and Firebase communication.

- **View**: `MoodTrackerView`, `HabitTrackerView`, `MoodHistoryView`  
  SwiftUI screens that present data and interact with the user.

- **Services**: `MoodService`, `MockMoodService`  
  Handles Firebase Firestore operations and mock testing.

- **UIKit Integration**: `ShareSheet`  
  Demonstrates UIKit interoperability within a SwiftUI app.

This modular architecture improves testability and scalability across the app.

---

## Core Features

### Mood Tracker
The Mood Tracker allows users to record their emotional states daily.  
It uses gesture controls for simple and intuitive interaction.

- Swipe left or right → Change mood  
- Swipe up or down → Adjust mood intensity  
- Tap “Save Mood” → Save to Firebase  
- Tap “View Mood History” → View saved moods

Each entry includes:
- Mood name (e.g., “😊 Happy”)  
- Intensity level (1–5)  
- Timestamp  
- User ID linked via Firebase Authentication  

---

### Habit Tracker
The Habit Tracker helps users set daily goals and maintain consistency.  

Main features:
- Create, edit, and delete tasks  
- Mark tasks as completed  
- Track progress and streaks  
- Save locally using SwiftData for offline use  

---

### Firebase and SwiftData Synchronization
Habood uses both **Firebase Firestore** (online) and **SwiftData** (offline).  

- Cloud sync: Firestore stores all mood and habit data  
- Local cache: SwiftData keeps data when offline  
- Authentication: Google Sign-In with FirebaseAuth  
- Automatic merge when reconnected  

---

### UIKit Integration
Habood demonstrates **SwiftUI + UIKit** integration using a **ShareSheet** component.

```swift
import UIKit
import SwiftUI

/// A UIKit-based share sheet integrated into the SwiftUI app.
public struct ShareSheet: UIViewControllerRepresentable {
    public var activityItems: [Any]
    public init(activityItems: [Any]) { self.activityItems = activityItems }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

Unit Tests

Habood includes five automated unit tests that verify main app logic:
    •    testSetMood() – Checks if mood selection updates correctly
    •    testIntensityRange() – Ensures intensity stays between 1 and 5
    •    testNextMoodCycle() – Verifies mood cycling logic
    •    testSaveWithoutSelection() – Displays warning when mood not selected
    •    testSaveMoodSuccess() – Confirms successful save message

All tests passed successfully 

⸻

Contributors

Yunlong Chen — s4099035
Mood Tracker, Firebase Integration, Unit Tests, DocC Documentation

Stephan Karatselios — s3904894
Habit Tracker, Authentication, UIKit Integration,HaboodUITests

⸻

License

This project was created for academic purposes as part of the RMIT iPSE course.
All code and materials are intended for educational use only.

© 2025 RMIT University — School of Computing Technologies
All rights reserved. Redistribution or commercial use is prohibited.

⸻

Last Updated: October 2025
Generated using Apple DocC in Xcode 16 by Yunlong Chen (s4099035).
