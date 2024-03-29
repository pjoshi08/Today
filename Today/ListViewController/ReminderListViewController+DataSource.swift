//
//  ReminderListViewController+DataSource.swift
//  Today
//
//  Created by Parth Joshi on 12/5/23.
//

import UIKit

extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Reminder.ID>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>
    
    var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder complete value")
    }
    
    var reminderNotCompletedValue: String {
        NSLocalizedString("Not completed", comment: "Reminder not complete value")
    }
    
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    func updateSnapshot(reloading idsThatChanged: [Reminder.ID] = []) {
        let ids = idsThatChanged.filter { id in filteredReminders.contains(where: { $0.id == id }) }
        var snapshot = SnapShot()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredReminders.map { $0.id })
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot)
        headerView?.progress = progress
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Reminder.ID) {
        let reminder = reminder(withId: id)
        var contentConfiguration = cell.defaultContentConfiguration()
        /// The list displays the configuration text as the primary text of a cell.
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(
            forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration
        
        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
        cell.accessibilityCustomActions = [doneButtonAccessibilityAction(for: reminder)]
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue
        /// You can create colors several ways: by providing red, green, and blue components; by providing hue, saturation, and brightness values; or by providing a single white value for grayscale colors. Try using these UIColor initializers to create other button tint colors. If you need help, refer to the Color creation docs.
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration), .disclosureIndicator(displayed: .always)
        ]
        
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        /// backgroundConfiguration.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.9, alpha: 1.0)
        backgroundConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroundConfiguration
    }
    
    func reminder(withId id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(withId: id)
        return reminders[index]
    }
    
    func updateReminder(_ reminder: Reminder) {
        do {
            try reminderStore.save(reminder)
            let index = reminders.indexOfReminder(withId: reminder.id)
            reminders[index] = reminder
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    }
    
    func completeReminder(withId id: Reminder.ID) {
        var reminder = reminder(withId: id)
        reminder.isComplete.toggle()
        updateReminder(reminder)
        updateSnapshot(reloading: [id])
    }
    
    func addReminder(_ reminder: Reminder) {
        /// EventKit assigns unique identifiers to reminders. You’ll start by creating a mutable copy of the reminder so that it can receive its new identifier.
        /// Swift function parameters are constants by default. You declared a local variable so that you can mutate its properties within the function.
        var reminder = reminder
        do {
            let idFromStore = try reminderStore.save(reminder)
            reminder.id = idFromStore
            reminders.append(reminder)
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    }
    
    func deleteReminder(withId id: Reminder.ID) {
        do {
            try reminderStore.remove(with: id)
            let index = reminders.indexOfReminder(withId: id)
            reminders.remove(at: index)
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    }
    
    /// You must call functions marked as async from within a Task or another asynchronous function.
    func prepareReminderStore() {
        /// By creating a Task, you create a new unit of work that executes asynchronously.
        Task {
            /// Add a do block that awaits access to the reminder store.
            do {
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(
                    self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                #if DEBUG
                reminders = Reminder.sampleData
                #endif
            } catch {
                /// Swift error handling has similarities to a switch statement. If a function in the do block throws an error, that error falls through until it finds a matching catch block.
                showError(error)
            }
            updateSnapshot()
        }
    }
    
    func reminderStoreChanged() {
        Task {
            reminders = try await reminderStore.readAll()
            updateSnapshot()
        }
    }
    
    private func doneButtonAccessibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction
    {
        let name = NSLocalizedString("Toggle completion", comment: "Reminder done button accessibility label")
        /// Weakly capture self in the closure’s capture list.
        /// By default, closures create a strong reference to external values that you use inside them. Specifying a weak reference to the view controller prevents a retain cycle.
        let action = UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(withId: reminder.id)
            return true
        }
        return action
    }
    
    private func doneButtonConfiguration(for reminder: Reminder) 
    -> UICellAccessory.CustomViewConfiguration 
    {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ReminderDoneButton()
        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)
        button.id = reminder.id
        /// You can configure a UIButton object to display one image when it’s in its normal state and a different image when it’s highlighted.
        button.setImage(image, for: .normal)
        /// You’ll add a done button cell accessory to the leading side of the reminder cell. You can also add checkmark, reorder, delete, and disclosure-indicator cell accessories to a list cell.
        return UICellAccessory.CustomViewConfiguration(
            customView: button, placement: .leading(displayed: .always))
    }
}
