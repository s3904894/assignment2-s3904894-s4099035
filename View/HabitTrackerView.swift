//
//  HabitTracker.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//

import FirebaseAuth
import SwiftUI

struct HabitTrackerView: View {
    @State private var habit = Habit()
    @State private var hasHabit = false
    @State private var isPresentingSetHabit = false
    @StateObject private var store = LoadFile()
    
    @State private var habits: [HabitEntryFirebase] = []
    private let habitService = HabitService()
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("Habit Tracker")
                    .font(.largeTitle).fontWeight(.bold)
                    .padding(100)
            }
            VStack(alignment: .center) {
                if hasHabit, !habit.name.isEmpty {
                    Text(habit.name)
                    Text(habit.frequency)
                }
            }
            VStack {
                Button("Set Habit") { isPresentingSetHabit = true
                }
                .fontWeight(.heavy)
                .buttonStyle(ShadowButtonStyle())
            }
            NavigationLink(isActive: $isPresentingSetHabit) {
                SetHabitView(hasHabit: $hasHabit)
            } label: { EmptyView() }
        }
    }
    
    private func fetchHabits() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "User not logged in."
            self.isLoading = false
            return
        }

        print(" Fetching habits for user: \(user.uid)")

        habitService.fetchHabits() { fetchedHabits, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Failed to fetch habits: \(error.localizedDescription)"
                } else if let fetchedHabits = fetchedHabits {
                    print(" Retrieved \(fetchedHabits.count) habit(s) from Firestore.")
                    for habit in fetchedHabits {
                        print(" \(habit.habit) | Intensity: \(habit.frequency)")
                    }
                    self.habits = fetchedHabits
                } else {
                    self.errorMessage = "No data returned from Firestore."
                }
            }
        }
    }
}

