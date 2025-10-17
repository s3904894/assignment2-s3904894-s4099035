//
//  HaboodWidget.swift
//  HaboodWidget
//
//  Created by Yunlong Chen on 2025/10/17.
//  Final Stable Version with DocC Comments
//

import WidgetKit
import SwiftUI
import FirebaseCore
import FirebaseFirestore

// MARK: - Firebase Initialization

/// A helper singleton that safely initializes **Firebase** inside the Widget Extension.
///
/// Firebase **must** be configured on the **main thread**; otherwise,
/// Firestore will throw:
/// _“Failed to get FirebaseApp instance. Please call FirebaseApp.configure() before using Firestore.”_
///
/// This manager guarantees that Firebase initialization runs only once,
/// even if `getTimeline()` is called multiple times.
///
/// Example:
/// ```swift
/// FirebaseWidgetManager.shared.configureFirebaseIfNeeded()
/// ```
final class FirebaseWidgetManager {
    /// Shared singleton instance for Widget Firebase setup.
    static let shared = FirebaseWidgetManager()

    /// Private initializer to prevent multiple instances.
    private init() {
        configureFirebaseIfNeeded()
    }

    /// Configures Firebase safely on the main thread, only once.
    func configureFirebaseIfNeeded() {
        if FirebaseApp.app() == nil {
            if Thread.isMainThread {
                FirebaseApp.configure()
                print(" Firebase configured for Widget Extension (main thread)")
            } else {
                DispatchQueue.main.async {
                    FirebaseApp.configure()
                    print(" Firebase configured for Widget Extension (dispatched to main)")
                }
            }
        }
    }
}

// MARK: - Timeline Entry

/// Represents one mood record displayed by the Widget.
///
/// Each timeline entry corresponds to one state of the user’s mood data,
/// fetched from **Firestore** and linked to their App Group UID.
///
/// - Parameters:
///   - `date`: When the entry was created (WidgetKit timeline)
///   - `mood`: The mood emoji + label (e.g. “ Happy”)
///   - `intensity`: Mood intensity (1–5 scale)
struct MoodEntry: TimelineEntry {
    let date: Date
    let mood: String
    let intensity: Int
}

// MARK: - Timeline Provider

/// Supplies mood data to the Widget timeline using **Firebase Firestore**.
///
/// 1. Initializes Firebase via `FirebaseWidgetManager`.
/// 2. Reads the current user's UID from the App Group (`group.com.habood.shared`).
/// 3. Queries Firestore for the most recent mood entry.
/// 4. Returns a single-entry timeline (auto-refresh every 30 mins).
///
/// If UID is not found, the widget displays "Not Logged In".
struct MoodProvider: TimelineProvider {

    /// Placeholder shown when data is still loading.
    func placeholder(in context: Context) -> MoodEntry {
        MoodEntry(date: Date(), mood: " Happy", intensity: 4)
    }

    /// Snapshot for preview or quick refresh.
    func getSnapshot(in context: Context, completion: @escaping (MoodEntry) -> Void) {
        completion(MoodEntry(date: Date(), mood: " Tired", intensity: 3))
    }

    /// Main logic: fetch the latest mood record from Firestore.
    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodEntry>) -> Void) {
        //  Step 1: Ensure Firebase is configured (on main thread)
        FirebaseWidgetManager.shared.configureFirebaseIfNeeded()
        print(" Firebase configured for Widget")

        //  Step 2: Read UID from shared App Group
        let sharedDefaults = UserDefaults(suiteName: "group.com.habood.shared")
        guard let uid = sharedDefaults?.string(forKey: "userUID") else {
            print(" No UID found in App Group — user not logged in.")
            let entry = MoodEntry(date: Date(), mood: "Not Logged In", intensity: 0)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
            completion(timeline)
            return
        }

        print(" Widget reading UID: \(uid)")

        //  Step 3: Fetch from Firestore
        let db = Firestore.firestore()
        db.collection("moods")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                var mood = "Unknown"
                var intensity = 0

                if let error = error {
                    print(" Firestore error: \(error.localizedDescription)")
                } else if let doc = snapshot?.documents.first {
                    mood = doc.data()["mood"] as? String ?? "Unknown"
                    intensity = doc.data()["intensity"] as? Int ?? 0
                    print(" Fetched Firestore document: \(mood) | Intensity: \(intensity)")
                } else {
                    print(" No Firestore document found for UID: \(uid)")
                }

                //  Step 4: Build timeline
                let entry = MoodEntry(date: Date(), mood: mood, intensity: intensity)
                let nextUpdate = Date().addingTimeInterval(1800) // refresh every 30 min
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)

                print(" Timeline completed — mood: \(mood), intensity: \(intensity)")
            }
    }
}

// MARK: - Widget UI View

/// SwiftUI view defining the Widget’s visual layout.
///
/// Displays:
/// - Current mood emoji
/// - Intensity value
/// - Fallback message if user not logged in
///
/// Example:
/// ```swift
/// HaboodWidgetEntryView(entry: MoodEntry(date: .now, mood: " Happy", intensity: 5))
/// ```
struct HaboodWidgetEntryView: View {
    var entry: MoodProvider.Entry

    var body: some View {
        VStack {
            Text("Mood Tracker")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(entry.mood)
                .font(.largeTitle)
                .bold()

            if entry.intensity > 0 {
                Text("Intensity: \(entry.intensity)/5")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("Sign in to view moods")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .containerBackground(Color(.systemBackground), for: .widget)
    }
}

// MARK: - Widget Configuration

/// Registers the Habood Widget with WidgetKit.
///
/// The widget connects to Firebase Firestore and displays the latest mood.
/// It refreshes automatically every 30 minutes.
///
/// - Features:
///   - Firebase & App Group integration
///   - Real-time mood display
///   - Main-thread-safe Firebase initialization
///   - Compact SwiftUI design
///
/// - Author: Yunlong Chen
@main
struct HaboodWidget: Widget {
    let kind: String = "HaboodWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoodProvider()) { entry in
            HaboodWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habood Mood Widget")
        .description("Displays your most recent mood and intensity from Firebase.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
