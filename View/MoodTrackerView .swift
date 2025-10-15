//
//  MoodTrackerView.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//  Modified by Yunlong Chen on 29/8/2025
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import UIKit

/// Main view for mood tracking — includes gesture interactions, Firebase integration, and a UIKit ShareSheet feature
struct MoodTrackerView: View {
    @StateObject private var viewModel = MoodTrackerViewModel()
    @State private var isShowingHistory = false
    @State private var dragOffset: CGSize = .zero
    @State private var showShare = false              // Controls the UIKit share sheet
    @State private var shareText = ""                 // Text content to share

    // Available mood options
    let moods = ["😊 Happy", "😢 Sad", "😡 Angry", "😴 Tired", "😰 Anxious"]

    var body: some View {
        VStack(spacing: 25) {
            // MARK: - Title
            Text("Mood Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("How are you feeling today?")
                .font(.headline)

            // MARK: - Display selected mood
            Text(viewModel.selectedMood.isEmpty ? "No mood selected" : viewModel.selectedMood)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(.bottom, 10)

            // MARK: - Mood selector with swipe gesture
            VStack {
                Text("Swipe left or right to change mood")
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
                    // Swipe gesture: left/right to change mood
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

            // MARK: - Mood intensity slider + up/down gesture
            VStack {
                Text("Intensity: \(viewModel.intensity)")
                    .font(.subheadline)

                Slider(value: Binding(
                    get: { Double(viewModel.intensity) },
                    set: { viewModel.setIntensity(Int($0)) }
                ), in: 1...5, step: 1)
                .padding(.horizontal, 40)

                Text("Drag up or down to adjust intensity")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            // Drag gesture for intensity control
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height < -30 {
                            // Drag up → increase intensity
                            viewModel.setIntensity(viewModel.intensity + 1)
                        } else if gesture.translation.height > 30 {
                            // Drag down → decrease intensity
                            viewModel.setIntensity(viewModel.intensity - 1)
                        }
                    }
            )

            // MARK: - Save mood button
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

            // MARK: - UIKit ShareSheet button
            Button("Share My Mood") {
                // Compose the text for sharing
                shareText = viewModel.selectedMood.isEmpty
                    ? "I'm not sure how I feel today "
                    : "Today I feel \(viewModel.selectedMood) with intensity \(viewModel.intensity)/5."
                showShare = true
            }
            .fontWeight(.bold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            // UIKit ShareSheet integration
            .sheet(isPresented: $showShare) {
                ShareSheet(activityItems: [shareText])
            }

            // MARK: - Navigation to Mood History
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
