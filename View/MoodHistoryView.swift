//
//  MoodHistoryView.swift
//  Habood
//
//  Created by yunlong chen on 2025/8/31.


import SwiftUI
import FirebaseAuth

struct MoodHistoryView: View {
    @State private var moods: [MoodEntryFirebase] = []
    private let moodService = MoodService()
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            Text("Mood History")
                .font(.largeTitle)
                .bold()
                .padding(.top, 30)

            if isLoading {
                ProgressView("Loading your mood history...")
                    .padding()
            } else if let error = errorMessage {
                Text(" \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if moods.isEmpty {
                Spacer()
                Text("No mood history yet ")
                    .foregroundColor(.gray)
                Spacer()
            } else {
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fetchMoods()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Fetch moods from Firebase
    private func fetchMoods() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "User not logged in."
            self.isLoading = false
            return
        }

        print(" Fetching moods for user: \(user.uid)")

        moodService.fetchMoods { fetchedMoods, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Failed to fetch moods: \(error.localizedDescription)"
                } else if let fetchedMoods = fetchedMoods {
                    print(" Retrieved \(fetchedMoods.count) mood(s) from Firestore.")
                    for mood in fetchedMoods {
                        print(" \(mood.mood) | Intensity: \(mood.intensity)")
                    }
                    self.moods = fetchedMoods
                } else {
                    self.errorMessage = "No data returned from Firestore."
                }
            }
        }
    }
}
