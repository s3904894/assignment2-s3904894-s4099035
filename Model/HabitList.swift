//
//  HabitList.swift
//  Habood
//
//  Created by Stephan Karatselios on 29/8/2025.
//

import Foundation

struct HabitList: Identifiable, Codable {
    let id: Int
    let habit: String
    let frequency: String
}
