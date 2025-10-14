//
//  LoadFile.swift
//  Habood
//
//  Created by Stephan Karatselios on 29/8/2025.
//

import Foundation

@MainActor
final class LoadFile: ObservableObject {
    @Published var items: [HabitList] = []
    
    func saveToJsonFile(_ habitlist: Habit) {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else  { return }
        _ = documentDirectoryUrl.appendingPathComponent("habitlist.json")
    }
    
    func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "habitlist",
                                        withExtension: "json") else {
            #if DEBUG
            print("❌ Missing todos.json in app bundle")
            #endif
            return 
        }
        do {
            let data = try Data(contentsOf: url)
            items = try JSONDecoder().decode([HabitList].self, from: data)
        } catch {
#if DEBUG
print("❌ Failed to decode todos.json:", error)
#endif
        }
    }
}
