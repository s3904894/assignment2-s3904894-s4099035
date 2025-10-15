//
//  HabitTrackerViewModel.swift
//  Habood
//
//  Created by Stephan Karatselios on 14/10/2025.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class HabitTrackerViewModel: ObservableObject {
    @Published var habitName: String = ""
    @Published var frequencyIndex: Int = 0
    @Published var saveMessage: String? = nil
    @Published var isSaving: Bool = false
    
    let frequencyOptions = ["Daily", "Weekly", "Fortnightly", "Monthly"]
    private let habitService = HabitService()
    
    var selectedFrequency: String { frequencyOptions[frequencyIndex] }
    
    
    
    
    func setHabit(_ name: String) {
        habitName = name
    }
    
    func setFrequency(_ index: Int) {
        guard index >= 0 && index < frequencyOptions.count else { return }
        frequencyIndex = index
    }
    
    
    func save(completion: @escaping (Bool) -> Void) {
        let trimmed = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            saveMessage = "Enter a habit name."
            completion(false)
            return
        }
        
        func save(completion: @escaping (Bool) -> Void) {
            let trimmed = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                saveMessage = "Enter a habit name."
                completion(false)
                return
            }
        }
    }    
}
