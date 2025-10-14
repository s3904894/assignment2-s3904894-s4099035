//
//  MakeHabit.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//

import SwiftUI


struct SetHabitView: View {
    @Binding var hasHabit: Bool

    @State private var habitName: String = ""
    @State private var previewIndex = 0
    private let options = ["Daily", "Weekly", "Fortnightly", "Monthly"]
    let loadJson = LoadFile()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        var newHabit = Habit(name: habitName, frequency: options[previewIndex])
        VStack {
            Text("Set Habit")
                .font(.largeTitle).fontWeight(.bold)
                .padding(100)

            Form {
                Section(header: Text("Habit")) {
                    TextField("Enter a habit", text: $habitName)
                }
                Section(header: Text("Frequency")) {
                    Picker("Set Frequency", selection: $previewIndex) {
                        ForEach(0 ..< 4) {
                            Text(self .options[$0])
                        }
                    }
                }
            }

            Button("Set Habit") {
                
                loadJson.saveToJsonFile(newHabit)
                hasHabit = true
                dismiss()   // go back to HabitTrackerView
            }
            .onAppear {
            }
            .fontWeight(.heavy)
            .buttonStyle(ShadowButtonStyle())
        }
    }
    
}

