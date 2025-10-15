//
//  MakeHabit.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//

import SwiftUI



struct SetHabitView: View {
    @Binding var hasHabit: Bool
    @StateObject private var habitTrackerViewModel = HabitTrackerViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Set Habit")
                .font(.largeTitle).fontWeight(.bold)
                .padding(.top, 32)
            
            Form {
                Section(header: Text("Habit")) {
                    TextField("Enter a habit", text: $habitTrackerViewModel.habitName)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Frequency")) {
                    Picker("Set Frequency", selection: $habitTrackerViewModel.frequencyIndex) {
                        ForEach(habitTrackerViewModel.frequencyOptions.indices, id: \.self) { i in
                            Text(habitTrackerViewModel.frequencyOptions[i]).tag(i)
                        }
                    }
                }
                
                if let msg = habitTrackerViewModel.saveMessage, !msg.isEmpty {
                    Section {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(msg.hasPrefix("Failed") ? .red : .green)
                    }
                }
            }
            
            Button {
                habitTrackerViewModel.save { success in
                    if success {
                        hasHabit = true
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    if habitTrackerViewModel.isSaving { ProgressView().padding(.trailing, 6) }
                    Text("Save Habit").fontWeight(.heavy)
                }
            }
            .disabled(habitTrackerViewModel.isSaving || habitTrackerViewModel.habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(ShadowButtonStyle())
            .padding(.vertical, 12)
        }
    }
}

