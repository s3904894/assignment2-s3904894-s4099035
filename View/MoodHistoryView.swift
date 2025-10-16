//
//  MoodHistoryView.swift
//  Habood
//
//  Created by Yunlong Chen on 2025/8/31.
//

import SwiftUI
import FirebaseAuth

/// A SwiftUI view that displays the user’s mood history retrieved from Firebase Firestore.
///
/// The `MoodHistoryView` fetches all previously saved moods for the logged-in user
/// and presents them in a scrollable list. Each entry includes:
/// - The recorded mood (emoji + text)
/// - The mood intensity (1–5)
/// - The date and time when it was saved
///
/// If no moods are found, a message is shown to the user.
/// If the user is not signed in, an authentication warning appears.
///
/// - SeeAlso: `MoodService`, `MoodTrackerView`
/// - Author: Yunlong Chen
struct MoodHistoryView: View {
    //  Properties

    /// The array of mood entries retrieved from Firebase.
    @State private var moods: [MoodEntry] = []

    /// A reference to the Firebase data service.
    private let moodService = MoodService()

    /// Indicates whether the app is currently loading data.
    @State private var isLoading = true

    /// Stores an error message if data retrieval fails.
    @State private var errorMessage: String? = nil

    // View Body

    var body: some View {
        VStack {
            // Title
            Text("Mood History")
                .font(.largeTitle)
                .bold()
                .padding(.top, 30)

            // State Handling
            if isLoading {
                /// Displays a loading spinner while data is being fetched.
                ProgressView("Loading your mood history...")
                    .padding()
            } else if let error = errorMessage {
                /// Displays an error message if fetching failed.
                Text("\(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if moods.isEmpty {
                /// Displays a placeholder when there are no saved moods.
                Spacer()
                Text("No mood history yet")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                /// Displays a list of all mood entries.
                List(moods) { mood in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(mood.mood)
                            .font(.headline)
                        Text("Intensity: \(mood.intensity)")
                            .font(.subheadline)
                        Text("Date: \(mood.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .listStyle(.inset)
            }
        }
        .onAppear {
            /// Delays fetching slightly to simulate a smoother loading animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fetchMoods()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // Firebase Data Fetching

    /// Fetches the user’s saved moods from Firebase Firestore.
    ///
    /// This function calls the `MoodService.fetchMoods()` method,
    /// retrieves the list of moods associated with the logged-in user’s UID,
    /// and updates the local `moods` state variable for display.
    ///
    /// Example:
    /// ```swift
    /// moodService.fetchMoods { fetchedMoods, error in
    ///     if let moods = fetchedMoods {
    ///         self.moods = moods
    ///     }
    /// }
    /// ```
    private func fetchMoods() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "User not logged in."
            self.isLoading = false
            return
        }

        print("Fetching moods for user: \(user.uid)")

        moodService.fetchMoods { fetchedMoods, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to fetch moods: \(error.localizedDescription)"
                } else if let fetchedMoods = fetchedMoods {
                    print("Retrieved \(fetchedMoods.count) mood(s) from Firestore.")
                    for mood in fetchedMoods {
                        print("\(mood.mood) | Intensity: \(mood.intensity)")
                    }

                    // Converts Firebase data model into local SwiftData-compatible model
                    self.moods = fetchedMoods.map { firebaseMood in
                        MoodEntry(
                            id: firebaseMood.id,
                            mood: firebaseMood.mood,
                            intensity: firebaseMood.intensity,
                            createdAt: firebaseMood.createdAt
                        )
                    }
                } else {
                    self.errorMessage = "No data returned from Firestore."
                }
            }
        }
    }
}
