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

/// The main SwiftUI view that allows users to record, view, and share their moods.
///
/// The **MoodTrackerView** provides an interactive user interface for:
/// - Selecting moods using **swipe gestures**
/// - Adjusting mood intensity using **up/down drag gestures**
/// - Saving moods to **Firebase Firestore**
/// - Viewing mood history through a navigation link
/// - Sharing mood via a **UIKit ShareSheet**
///
/// This is the central user-facing feature of the **Habood** wellbeing app.
///
/// - SeeAlso: `MoodTrackerViewModel`, `MoodHistoryView`, `ShareSheet`
/// - Author: Yunlong Chen
struct MoodTrackerView: View {
    //  Properties

    /// The ViewModel that manages logic, mood state, and Firebase saving.
    @StateObject private var viewModel = MoodTrackerViewModel()

    /// Controls navigation to the Mood History view.
    @State private var isShowingHistory = false

    /// Tracks drag offset used for gesture detection.
    @State private var dragOffset: CGSize = .zero

    /// Controls whether the UIKit ShareSheet is presented.
    @State private var showShare = false

    /// The text content to share in the ShareSheet.
    @State private var shareText = ""

    /// The list of available mood options that the user can swipe between.
    let moods = ["😊 Happy", "😢 Sad", "😡 Angry", "😴 Tired", "😰 Anxious"]

    //  Main View Body
    var body: some View {
        VStack(spacing: 25) {

            //  Title Section
            Text("Mood Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("How are you feeling today?")
                .font(.headline)

            //  Selected Mood Display
            Text(viewModel.selectedMood.isEmpty ? "No mood selected" : viewModel.selectedMood)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(.bottom, 10)

            //  Mood Selector with Swipe Gesture
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
                    /// Detects horizontal swipes to change mood.
                    /// - Left Swipe: moves to the next mood.
                    /// - Right Swipe: moves to the previous mood.
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

            //  Mood Intensity Controls
            VStack {
                Text("Intensity: \(viewModel.intensity)")
                    .font(.subheadline)

                /// A slider that controls the mood intensity value (1–5).
                Slider(value: Binding(
                    get: { Double(viewModel.intensity) },
                    set: { viewModel.setIntensity(Int($0)) }
                ), in: 1...5, step: 1)
                .padding(.horizontal, 40)

                Text("Drag up or down to adjust intensity")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            /// Detects vertical drag gestures to adjust mood intensity.
            /// - Up Drag: Increases intensity.
            /// - Down Drag: Decreases intensity.
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height < -30 {
                            viewModel.setIntensity(viewModel.intensity + 1)
                        } else if gesture.translation.height > 30 {
                            viewModel.setIntensity(viewModel.intensity - 1)
                        }
                    }
            )

            //  Save Mood Button
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

            //  UIKit ShareSheet Integration
            Button("Share My Mood") {
                /// Prepares the text that will be shared using UIKit’s ShareSheet.
                shareText = viewModel.selectedMood.isEmpty
                    ? "I'm not sure how I feel today."
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
            /// Presents the UIKit share sheet (UIActivityViewController).
            .sheet(isPresented: $showShare) {
                ShareSheet(activityItems: [shareText])
            }

            //  Navigation to Mood History
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
        /// When the view appears, initializes the default mood.
        .onAppear {
            if viewModel.selectedMood.isEmpty {
                viewModel.setMood(moods[0])
            }
        }
    }
}
