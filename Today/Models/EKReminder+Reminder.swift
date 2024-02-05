//
//  EKReminder+Reminder.swift
//  Today
//
//  Created by Parth Joshi on 1/29/24.
//

import Foundation
import EventKit

extension EKReminder {
    func update(using reminder: Reminder, in store: EKEventStore) {
        title = reminder.title
        notes = reminder.notes
        isCompleted = reminder.isComplete
        /// EventKit calendar items must be associated with a calendar.
        /// The user can change their default calendar in the Settings app.
        calendar = store.defaultCalendarForNewReminders()
        /// Recall that EventKit uses a combination of alarms and the due date to determine when to remind a user of an action. Today uses only the due date. You need to remove any excess alarms from the record.
        alarms?.forEach { alarm in
            guard let absoluteDate = alarm.absoluteDate else { return }
            let comparison = Locale.current.calendar.compare(
                reminder.dueDate, to: absoluteDate, toGranularity: .minute)
            if comparison != .orderedSame {
                removeAlarm(alarm)
            }
        }
        /// The reminder must have one alarm in order to trigger a system notification when it’s due.
        if !hasAlarms {
            addAlarm(EKAlarm(absoluteDate: reminder.dueDate))
        }
    }
}
