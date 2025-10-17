//
//  HabitTrackerViewModel.swift
//  Habood
//
//  Created by Stephan Karatselios on 14/10/2025.
//
import Foundation
import SwiftData

/**
 State holder for the habit list and creation flow.

 ## Properties
 - ``habits``: in-memory list from the service.
 - ``isLoading`` and ``errorMessage``: fetch state.
 - ``habitName`` and ``frequencyIndex``: creation inputs.

 ## Methods
 - ``fetchHabits()``: loads from the backing service.
 - ``saveHabit(completion:)``: validates and creates.

 ## Threading
 Marked `@MainActor` to update UI-bound state safely.
 */


@MainActor
final class HabitTrackerViewModel: ObservableObject {
    
    @Published var habits: [HabitEntryFirebase] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var habitName = ""
    let frequencyOptions = ["Daily", "Weekly", "Fortnightly", "Monthly"]
    @Published var frequencyIndex = 0
    @Published var isSaving = false
    @Published var saveMessage: String?
    private let service = HabitService()
    var modelContext: ModelContext?
    
    func fetchHabits() {
        isLoading = true; errorMessage = nil
        service.fetchHabits { [weak self] items, err in
            Task { @MainActor in
                self?.isLoading = false
                if let err = err { self?.errorMessage = err.localizedDescription; return }
                self?.habits = items ?? []
            }
        }
    }

    func saveHabit(completion: @escaping (Bool) -> Void) {
        let name = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            saveMessage = "Failed: Habit name required"
            completion(false); return
        }
        let frequency = frequencyOptions[frequencyIndex]
        isSaving = true
        saveMessage = nil
        service.addHabit(name: name, frequency: frequency) { [weak self] err in
            Task { @MainActor in
                guard let self else {
                    return
                }
                self.isSaving = false
                if let err = err {
                    self.saveMessage = "Failed: \(err.localizedDescription)"
                    completion(false); return
                }
                self.saveMessage = "Saved"
                self.habitName = ""; self.frequencyIndex = 0
                self.fetchHabits()

                if let context = self.modelContext,
                   let settings = try? context.fetch(FetchDescriptor<SettingsItem>()).first,
                   settings.notifications {
                    self.service.fetchHabits { items, _ in
                        let newId = items?.first?.id ?? UUID().uuidString 
                        SettingsViewModel.viewModel.schedule(
                            habitId: newId,
                            title: name,
                            frequency: HabitFrequency(rawValue: frequency) ?? .Daily,
                            createdAt: Date(),
                            hour: settings.reminderHour,
                            minute: settings.reminderMinute
                        )
                    }
                }
                completion(true)
            }
        }
    }

    func delete(at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        let id = habits[index].id
        service.deleteHabit(id: id) { [weak self] err in
            Task { @MainActor in
                if err == nil {
                    SettingsViewModel.viewModel.cancel(habitId: id)
                    self?.habits.remove(atOffsets: offsets)
                } else {
                    self?.errorMessage = err!.localizedDescription
                }
            }
        }
    }
}
