//
//  ReminderStore.swift
//  Today
//
//  Created by Parth Joshi on 1/15/24.
//

import Foundation
import EventKit

/// You can’t override methods in final classes. The compiler will display a warning if you try to subclass ReminderStore.
final class ReminderStore {
    static let shared = ReminderStore()
    
    private let ekStore = EKEventStore()
    
    /// For now, you’ll use this property to determine if the user has granted access to their reminder data. You’ll learn in an upcoming section how to request access to their reminder data.
    var isAvailable: Bool {
        //EKEventStore.authorizationStatus(for: .reminder) == .authorized
        EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
    }
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        /// The function will return if the user has granted access, ask permission if the user hasn’t yet decided, or throw an error for other conditions.
        switch status {
        case .authorized:
            return
        case .restricted:
            throw TodayError.accessRestricted
        case .notDetermined:
            //let accessGranted = try await ekStore.requestAccess(to: .reminder)
            var accessGranted = false
            if #available(iOS 17.0, *) {
                accessGranted = try await ekStore.requestFullAccessToReminders()
            } else {
                accessGranted = try await ekStore.requestAccess(to: .reminder)
            }
            guard accessGranted else {
                throw TodayError.accessDenied
            }
        case .denied:
            throw TodayError.accessDenied
        case .fullAccess:
            return
        case .writeOnly:
            return
        @unknown default:
            /// Your app would work without the @unknown attribute before the default keyword. However, adding the attribute instructs the compiler to warn you if future versions of the API add new cases to the enumeration.
            throw TodayError.unknown
        }
    }
    
    func readAll() async throws -> [Reminder] {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        
        /// This predicate narrows the results to only reminder items. If you choose, you can further narrow the results to reminders from specific calendars.
        let predicate = ekStore.predicateForReminders(in: nil)
        /// The await keyword indicates that your task suspends until the results become available, at which point your task resumes and assigns the results to the ekReminders constant.
        let ekReminders = try await ekStore.reminders(matching: predicate)
        /// compactMap(_:) works as both a filter and a map, allowing you to discard items from the source collection.
        let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
            do {
                return try Reminder(with: ekReminder)
            } catch TodayError.reminderHasNoDueDate {
                /// By returning nil, you instruct the compact map to discard this reminder from the destination collection.
                return nil
            }
        }
        return reminders
    }
    
    /// You won’t use the identifier that this method returns in all situations. The @discardableResult attribute instructs the compiler to omit warnings in cases where the call site doesn’t capture the return value.
    @discardableResult
    func save(_ reminder: Reminder) throws -> Reminder.ID {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder: EKReminder
        do {
            ekReminder = try read(with: reminder.id)
        } catch {
            ekReminder = EKReminder(eventStore: ekStore)
        }
        ekReminder.update(using: reminder, in: ekStore)
        try ekStore.save(ekReminder, commit: true)
        return ekReminder.calendarItemIdentifier
    }
    
    func remove(with id: Reminder.ID) throws {
        guard isAvailable else { throw TodayError.accessDenied }
        let ekReminder = try read(with: id)
        try ekStore.remove(ekReminder, commit: true)
    }
    
    private func read(with id: Reminder.ID) throws -> EKReminder {
        /// Because the method calendarItem(withIdentifier:) returns the superclass EKCalendarItem, you downcast to EKReminder. The downcast ensures that you can safely treat the item as an EKReminder.
        guard let ekReminder = ekStore.calendarItem(withIdentifier: id) as? EKReminder else {
            throw TodayError.failedReadingCalenderItem
        }
        return ekReminder
    }
}
