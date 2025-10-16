//
//  SettingsViewModel.swift
//  Habood
//
//  Created by Stephan Karatselios on 16/10/2025.
//

import Foundation
import UserNotifications

enum HabitFrequency: String {
    case Daily, Weekly, Fortnightly, Monthly
}

final class SettingsViewModel {
    
    static let viewModel = SettingsViewModel()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func schedule(habitId: String, title: String, frequency: HabitFrequency, createdAt: Date, hour: Int, minute: Int) {
        cancel(habitId: habitId)
        let content = UNMutableNotificationContent()
        content.title = "Habit reminder"
        content.body = title
        content.sound = .default
        let center = UNUserNotificationCenter.current()
        switch frequency {
        case .Daily:
            var date = DateComponents(); date.hour = hour; date.minute = minute
            center.add(.init(identifier: habitId,
                             content: content,
                             trigger: UNCalendarNotificationTrigger(dateMatching: date, repeats: true)))

        case .Weekly:
            let weekly = Calendar.current.component(.weekday, from: createdAt)
            var date = DateComponents(); date.weekday = weekly; date.hour = hour; date.minute = minute
            center.add(.init(identifier: habitId,
                             content: content,
                             trigger: UNCalendarNotificationTrigger(dateMatching: date, repeats: true)))

        case .Fortnightly:
            let next = nextFireDate(from: Date(), hour: hour, minute: minute)
            let initial = max(1, Int(next.timeIntervalSinceNow))
            center.add(.init(identifier: habitId + ".first",
                             content: content,
                             trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(initial), repeats: false)))
            center.add(.init(identifier: habitId + ".repeat",
                             content: content,
                             trigger: UNTimeIntervalNotificationTrigger(timeInterval: 14 * 24 * 3600, repeats: true)))

        case .Monthly:
            var date = DateComponents()
            date.day = Calendar.current.component(.day, from: createdAt)
            date.hour = hour; date.minute = minute
            center.add(.init(identifier: habitId,
                             content: content,
                             trigger: UNCalendarNotificationTrigger(dateMatching: date, repeats: true)))
        }
    }

    func cancel(habitId: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [habitId, habitId + ".first", habitId + ".repeat"])
    }

    func saveSchedule(habits: [HabitEntryFirebase], hour: Int, minute: Int, enabled: Bool) {
        if !enabled { UNUserNotificationCenter.current().removeAllPendingNotificationRequests(); return }
        for h in habits {
            let f = HabitFrequency(rawValue: h.frequency) ?? .Daily
            schedule(habitId: h.id, title: h.habit, frequency: f, createdAt: h.createdAt, hour: hour, minute: minute)
        }
    }

    private func nextFireDate(from base: Date, hour: Int, minute: Int) -> Date {
        var date = Calendar.current.dateComponents([.year, .month, .day], from: base)
        date.hour = hour; date.minute = minute
        let today = Calendar.current.date(from: date) ?? base
        return today > base ? today : Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
    }
}

