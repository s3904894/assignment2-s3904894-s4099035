//
//  SettingsView.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var rows: [SettingsItem]

    private var settings: SettingsItem {
        if let setting = rows.first {
            return setting
        }
        let setting = SettingsItem()
        context.insert(setting)
        try? context.save()
        return setting
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: Binding(
                        get: {
                            settings.darkMode
                        },
                        set: {
                            settings.darkMode = $0
                            try? context.save()
                        }
                    ))
                }

                Section("Notifications") {
                    Toggle("Enable habit reminders", isOn: Binding(
                        get: {
                            settings.notifications
                        },
                        set: {
                            settings.notifications = $0
                            saveAndReschedule()
                        }
                    ))
                    DatePicker(
                        "Reminder time",
                        selection: Binding(
                            get: {
                                Calendar.current.date(from: DateComponents(
                                    hour: settings.reminderHour,
                                    minute: settings.reminderMinute
                                )) ?? Date()
                            },
                            set: { date in
                                let calendar = Calendar.current.dateComponents([.hour,.minute], from: date)
                                settings.reminderHour = calendar.hour ?? 9
                                settings.reminderMinute = calendar.minute ?? 0
                                saveAndReschedule()
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }

                Section {
                    Button(role: .destructive, action: resetSettings) { Text("Reset settings") }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func saveAndReschedule() {
        try? context.save()
        HabitService().fetchHabits { items, _ in
            SettingsViewModel.viewModel.saveSchedule(
                habits: items ?? [],
                hour: settings.reminderHour,
                minute: settings.reminderMinute,
                enabled: settings.notifications
            )
        }
    }

    private func resetSettings() {
        settings.darkMode = false
        settings.notifications = false
        settings.reminderHour = 9
        settings.reminderMinute = 0
        saveAndReschedule()
    }
}
