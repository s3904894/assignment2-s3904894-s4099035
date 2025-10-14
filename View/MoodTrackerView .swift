//
//  MoodTrackerView.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//  Modified by Yunlong Chen on 29/8/2025
//
import SwiftUI
import Firebase

/// View for mood tracking — includes gesture interactions and Firebase integration
struct MoodTrackerView: View {
    @StateObject private var viewModel = MoodTrackerViewModel()
    @State private var isShowingHistory = false
    @State private var dragOffset: CGSize = .zero

    // Available mood options
    let moods = ["😊 Happy", "😢 Sad", "😡 Angry", "😴 Tired", "😰 Anxious"]

    var body: some View {
        VStack(spacing: 25) {
            Text("Mood Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("How are you feeling today?")
                .font(.headline)

            
            Text(viewModel.selectedMood.isEmpty ? "No mood selected" : viewModel.selectedMood)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(.bottom, 10)

            // Mood selector with swipe gesture
            VStack {
                Text("Swipe left or right to change mood ")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 100)
                    .cornerRadius(12)
                    .overlay(
                        Text(viewModel.selectedMood.isEmpty ? "😊 Happy" : viewModel.selectedMood)
                            .font(.title)
                            .bold()
                    )
                    // Add left/right swipe gesture
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                let index = moods.firstIndex(of: viewModel.selectedMood.isEmpty ? "😊 Happy" : viewModel.selectedMood) ?? 0
                                if gesture.translation.width < -50 {
                                    // Swipe left → next mood
                                    let nextIndex = (index + 1) % moods.count
                                    viewModel.setMood(moods[nextIndex])
                                } else if gesture.translation.width > 50 {
                                    // Swipe right → previous mood
                                    let prevIndex = (index - 1 + moods.count) % moods.count
                                    viewModel.setMood(moods[prevIndex])
                                }
                            }
                    )
                    .padding(.horizontal, 40)
            }

            // Mood intensity slider + gesture
            VStack {
                Text("Intensity: \(viewModel.intensity)")
                    .font(.subheadline)

                Slider(value: Binding(
                    get: { Double(viewModel.intensity) },
                    set: { viewModel.setIntensity(Int($0)) }
                ), in: 1...5, step: 1)
                .padding(.horizontal, 40)

                Text("Drag up/down to adjust intensity ")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            // Add up/down drag gesture
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height < -30 {
                            // Up = increase intensity
                            viewModel.setIntensity(viewModel.intensity + 1)
                        } else if gesture.translation.height > 30 {
                            // Down = decrease intensity
                            viewModel.setIntensity(viewModel.intensity - 1)
                        }
                    }
            )

            // Save button
            Button(action: {
                viewModel.saveMood()
            }) {
                Text("Save Mood")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)

            // Navigate to mood history
            NavigationLink(destination: MoodHistoryView(), isActive: $isShowingHistory) {
                Button("View Mood History") {
                    isShowingHistory = true
                }
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding(.bottom, 30)
        .onAppear {
            // Default first mood
            if viewModel.selectedMood.isEmpty {
                viewModel.setMood(moods[0])
            }
        }
    }
}

