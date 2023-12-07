//
//  Date+Today.swift
//  Today
//
//  Created by Parth Joshi on 12/4/23.
//

import Foundation

extension Date {
    /// Computed property represents date and time in a locale-aware format.
    var dayAndTimeText: String {
        let timeText = formatted(date: .omitted, time: .shortened)
        if Locale.current.calendar.isDateInToday(self) {
            let timeFormat = NSLocalizedString("Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText)
        } else {
            /// The formatted(_:) method uses a custom date format style to create a representation of the date that is appropriate for the user’s current locale.
            let dateText = formatted(.dateTime.month(.abbreviated).day())
            let dateAndTimeFormat = NSLocalizedString("%@ at %@", comment: "Date and time format string")
            return String(format: dateAndTimeFormat, dateText, timeText)
        }
    }
    
    /// Create a computed string property named dayText that returns a static string if this date is in the current calendar day.
    var dayText: String {
        if Locale.current.calendar.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Today due date description")
        } else {
            return formatted(.dateTime.month().day().weekday(.wide))
        }
    }
}
