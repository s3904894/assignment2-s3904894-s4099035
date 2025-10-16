//
//  MakeHabit.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//

import SwiftUI

struct SetHabitView: View {
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Set Habit")
                .font(.largeTitle).fontWeight(.bold)
                .padding(.top, 32)

            Form {
                Section("Habit") {
                    TextField("Enter a habit", text: $viewModel.habitName)
                        .textInputAutocapitalization(.words)
                }
                Section("Frequency") {
                    Picker("Set Frequency", selection: $viewModel.frequencyIndex) {
                        ForEach(viewModel.frequencyOptions.indices, id: \.self) { i in
                            Text(viewModel.frequencyOptions[i]).tag(i)
                        }
                    }
                }
                if let msg = viewModel.saveMessage, !msg.isEmpty {
                    Section { Text(msg).font(.footnote)
                            .foregroundColor(msg.hasPrefix("Failed") ? .red : .green) }
                }
            }

            Button {
                viewModel.saveHabit {
                    ok in if ok { dismiss()
                    }
                }
            }
            label: {
                HStack {
                    if viewModel.isSaving {
                        ProgressView().padding(.trailing, 6)
                    }
                    Text("Save Habit").fontWeight(.heavy)
                }
            }
            .disabled(viewModel.isSaving || viewModel.habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(ShadowButtonStyle())
            .padding(.vertical, 12)
        }
    }
}


