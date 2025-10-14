//
//  SettingsView.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//
import SwiftUI

struct SettingsView: View {
    // persisted user prefs
    @AppStorage("defaultFrequency") private var darkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    private let frequencies = ["Daily", "Weekly", "Fortnightly", "Monthly"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Background") {
                    Toggle("Dark Mode", isOn: $darkMode)
                }

                Section("Notifications") {
                    Toggle("Enable reminders", isOn: $notificationsEnabled)
                    Text("Scheduling to be added when Firebase/SwiftData are in place.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("General") {
                    Toggle("Haptics", isOn: $hapticsEnabled)
                    Button(role: .destructive) {
                        resetSettings()
                    } label: {
                        Text("Reset settings")
                    }
                }

                Section {
                    HStack {
                        Text("App version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func resetSettings() {
        UserDefaults.standard.removeObject(forKey: "defaultFrequency")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "hapticsEnabled")
    }
}
