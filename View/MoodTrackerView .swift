//
//  MoodTrackerView.swift
//  Habood
//
//Created by Stephan Karatselios on 28/8/2025.
//Created by Yunlong Chen on 2025/10/17.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import WidgetKit

// MARK: - MoodTrackerView
/// A minimalist and Apple-style SwiftUI interface for recording, saving, and sharing user moods.
///
/// The `MoodTrackerView` provides a smooth, distraction-free experience inspired by the iOS Settings design.
/// It integrates with Firebase Firestore and WidgetKit to synchronize and display user moods.
///
/// ## Features
/// - Select mood from a dropdown picker
/// - Adjust mood intensity using a clean slider
/// - Save moods to Firebase Firestore
/// - Share mood via system share sheet (UIKit)
/// - View previously saved moods in history
///
/// ## Design Philosophy
/// - Clean and calm Apple aesthetic
/// - Rounded white components with subtle shadows
/// - Adaptive background using system colors
///
/// - Author: **Yunlong Chen**
/// - Version: 1.0
/// - Date: October 2025
struct MoodTrackerView: View {
    
    // MARK: - Properties
    
    /// The currently selected mood value (e.g., “Happy” or “Sad”).
    @State private var selectedMood: String = ""
    
    /// The numeric mood intensity value (range: 1–5).
    @State private var intensity: Double = 3
    
    /// Stores the user-facing status message (success or error).
    @State private var saveMessage: String?
    
    /// Controls navigation to the Mood History screen.
    @State private var isShowingHistory = false
    
    /// Controls presentation of the system share sheet.
    @State private var isShowingShareSheet = false
    
    /// A predefined list of moods available for user selection.
    private let moods = [" Happy", " Sad", " Angry", " Tired", " Anxious"]
    
    /// A reference to the Firestore database instance.
    private let db = Firestore.firestore()
    
    // MARK: - Body
    /// The main user interface layout for the mood tracker screen.
    ///
    /// Uses a scrollable vertical layout that displays:
    /// - Mood picker
    /// - Intensity slider
    /// - Three main action buttons (Save, Share, View History)
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    
                    // MARK: Mood Picker Section
                    moodPickerSection
                    
                    // MARK: Intensity Slider
                    intensitySliderSection
                    
                    // MARK: Buttons Section
                    buttonsSection
                }
                .padding()
                .navigationTitle("Mood Tracker")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isShowingHistory) {
                    MoodHistoryView()
                }
                .sheet(isPresented: $isShowingShareSheet) {
                    if !selectedMood.isEmpty {
                        let shareText = "Today I feel \(selectedMood) with intensity \(Int(intensity))/5."
                        ActivityViewController(activityItems: [shareText])
                    }
                }
                .alert("Info", isPresented: .constant(saveMessage != nil)) {
                    Button("OK") { saveMessage = nil }
                } message: {
                    Text(saveMessage ?? "")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // MARK: - UI Components
    
    /// Displays the mood picker section with a labeled dropdown menu.
    ///
    /// Allows users to select a mood from predefined options.
    private var moodPickerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MOOD")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            HStack {
                Text("Select your mood")
                    .foregroundColor(.primary)
                Spacer()
                
                Picker("", selection: $selectedMood) {
                    ForEach(moods, id: \.self) { mood in
                        Text(mood).tag(mood)
                    }
                }
                .pickerStyle(.menu)
                .tint(.gray)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.separator), lineWidth: 0.4)
            )
        }
    }
    
    /// Displays the mood intensity slider and level indicator.
    ///
    /// Allows users to select intensity levels from 1 to 5 with smooth animation.
    private var intensitySliderSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("INTENSITY")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 10) {
                Slider(value: $intensity, in: 1...5, step: 1)
                    .tint(Color(UIColor.systemBlue))
                Text("Level: \(Int(intensity))/5")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.separator), lineWidth: 0.4)
            )
        }
    }
    
    /// Displays all main action buttons in a vertical stack.
    ///
    /// Includes:
    /// - “Save Mood”
    /// - “Share My Mood”
    /// - “View Mood History”
    private var buttonsSection: some View {
        VStack(spacing: 12) {
            MoodButton(title: "Save Mood") {
                saveMood()
            }
            MoodButton(title: "Share My Mood") {
                isShowingShareSheet = true
            }
            MoodButton(title: "View Mood History") {
                isShowingHistory = true
            }
        }
    }
    
    // MARK: - Firestore Saving
    /// Saves the current mood and intensity to Firestore under the logged-in user's account.
    ///
    /// - Important: The user must be authenticated via Firebase Authentication.
    ///
    /// If saving succeeds:
    /// - Displays confirmation alert (`Mood saved successfully!`)
    /// - Notifies WidgetKit to reload mood data via:
    /// ```swift
    /// WidgetCenter.shared.reloadAllTimelines()
    /// ```
    ///
    /// If saving fails:
    /// - Displays an error alert
    /// - Logs details in the console
    private func saveMood() {
        guard !selectedMood.isEmpty else {
            saveMessage = "Please select a mood."
            return
        }
        guard let user = Auth.auth().currentUser else {
            saveMessage = "Please log in to save moods."
            return
        }
        
        let data: [String: Any] = [
            "userId": user.uid,
            "mood": selectedMood,
            "intensity": Int(intensity),
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("moods").addDocument(data: data) { error in
            if let error = error {
                print("❌ Failed to save mood: \(error.localizedDescription)")
                saveMessage = "Failed to save mood."
            } else {
                print(" Mood saved successfully for user \(user.uid)")
                saveMessage = "Mood saved successfully!"
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

// MARK: - MoodButton
/// A reusable button component used across the mood tracker interface.
///
/// Displays a system-styled rounded button with a light shadow and blue accent text.
///
/// Example:
/// ```swift
/// MoodButton(title: "Save Mood") {
///     saveMood()
/// }
/// ```
private struct MoodButton: View {
    /// The button label text.
    let title: String
    
    /// The action performed when the button is tapped.
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundColor(Color(UIColor.systemBlue))
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
    }
}

// MARK: - ActivityViewController
/// A SwiftUI wrapper for UIKit’s `UIActivityViewController`.
///
/// This enables mood sharing through the native iOS Share Sheet.
///
/// Example:
/// ```swift
/// ActivityViewController(activityItems: ["Today I feel  Happy!"])
/// ```
struct ActivityViewController: UIViewControllerRepresentable {
    /// The list of items to share (e.g., text, images, or URLs).
    var activityItems: [Any]
    
    /// Creates the UIKit controller used to present the share sheet.
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    /// Updates the controller when SwiftUI state changes (no dynamic update needed here).
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

