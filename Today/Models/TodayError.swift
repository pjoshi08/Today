//
//  TodayError.swift
//  Today
//
//  Created by Parth Joshi on 1/10/24.
//

import Foundation

enum TodayError: LocalizedError {
    
    case accessDenied
    case accessRestricted
    case failedReadingCalenderItem
    case failedReadingReminders
    case reminderHasNoDueDate
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString(
                "The app doesn't have permission to read reminders.",
                comment: "access denied error description")
        case .accessRestricted:
            return NSLocalizedString(
                "This device doesn't allow access to reminders.",
                comment: "access restricted error description")
        case .failedReadingCalenderItem:
            return NSLocalizedString(
                "Failed to read a calender item", comment: "failed reading calender item error description")
        case .failedReadingReminders:
            return NSLocalizedString(
                "Failed to read reminders.", comment: "failed reading reminders error description")
        case .reminderHasNoDueDate:
            return NSLocalizedString(
                "A reminder has no due date.", comment: "reminder has no due date error description")
        case .unknown:
            return NSLocalizedString("An unknown error occurred", comment: "unknown error description")
        }
    }
}
