//
//  EkEventStore+AsyncFetch.swift
//  Today
//
//  Created by Parth Joshi on 1/15/24.
//

import Foundation
import EventKit

/// EKEventStore objects can access a user’s calendar events and reminders.
extension EKEventStore {
    func reminders(matching predicate: NSPredicate) async throws -> [EKReminder] {
        /// You use continuations to wrap concurrent callback functions so that their results can be returned inline.
        /// The await keyword indicates that your task suspends until the continuation resumes.
        /// Important: All paths of execution must resume the continuation.
        try await withCheckedThrowingContinuation { continuation in
            fetchReminders(matching: predicate) { reminders in
                /// if let reminders is the shortened Swift syntax for if let reminders = reminders.
                if let reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: TodayError.failedReadingReminders)
                }
            }
        }
    }
}
