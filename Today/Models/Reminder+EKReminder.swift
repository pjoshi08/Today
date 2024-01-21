//
//  Reminder+EKReminder.swift
//  Today
//
//  Created by Parth Joshi on 1/15/24.
//

import Foundation
import EventKit

extension Reminder {
    init(with ekReminder: EKReminder) throws {
        /// If a reminder has an alarm, the system presents a notification to the user when the reminder is due.
        guard let dueDate = ekReminder.alarms?.first?.absoluteDate else {
            throw TodayError.reminderHasNoDueDate
        }
        id = ekReminder.calendarItemIdentifier
        title = ekReminder.title
        self.dueDate = dueDate
        notes = ekReminder.notes
        isComplete = ekReminder.isCompleted
    }
}
