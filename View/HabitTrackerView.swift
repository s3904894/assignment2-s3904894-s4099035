//
//  HabitTracker.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//

import SwiftUI

/**
 List of saved habits.

 ## Overview
 Shows existing habits and supports refresh, delete, and navigation to create.

 ## Interactions
 - Pull or button to fetch habits.
 - Swipe/delete to remove a habit.
 - Add to open creation UI.
 */


struct HabitTrackerView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = HabitTrackerViewModel()
    @State private var isPresentingSetHabit = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Habit Tracker")
                    .font(.largeTitle).fontWeight(.bold)
                    .padding(.top, 40)

                if viewModel.isLoading {
                    ProgressView("Loading your habits...").padding()
                } else if let err = viewModel.errorMessage {
                    Text(err).foregroundStyle(.red).padding()
                } else if viewModel.habits.isEmpty {
                    Spacer(); Text("No habits yet").foregroundStyle(.secondary); Spacer()
                } else {
                    List {
                        ForEach(viewModel.habits) { h in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(h.habit).font(.headline)
                                Text("Frequency: \(h.frequency)").font(.subheadline)
                                Text("Date: \(h.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: viewModel.delete)
                    }
                    .listStyle(.inset)
                }

                Button("Set Habit") { isPresentingSetHabit = true }
                    .fontWeight(.heavy)
                    .buttonStyle(ShadowButtonStyle())
                    .padding(.bottom, 24)

                NavigationLink(isActive: $isPresentingSetHabit) {
                    SetHabitView().environmentObject(viewModel)
                } label: { EmptyView() }
            }
        }
        .onAppear {
            viewModel.modelContext = context
            viewModel.fetchHabits()
        }
    }
}
