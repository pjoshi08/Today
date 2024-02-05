//
//  ReminderListViewController+Actions.swift
//  Today
//
//  Created by Parth Joshi on 12/8/23.
//

import UIKit

extension ReminderListViewController {
    @objc func eventStoreChanged(_ notification: NSNotification) {
        reminderStoreChanged()
    }
    
    @objc func didPressDoneButton(_ sender: ReminderDoneButton) {
        guard let id = sender.id else { return }
        completeReminder(withId: id)
    }
    
    @objc func didPressAddButton(_ sender: UIBarButtonItem) {
        let reminder = Reminder(title: "", dueDate: Date.now)
        /// Add [weak self] to the closure’s capture list to prevent the reminder view controller from capturing and storing a strong reference to the reminder list view controller.
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.addReminder(reminder)
            /// you need to create and apply a snapshot to update the user interface whenever the app’s data changes.
            self?.updateSnapshot()
            self?.dismiss(animated: true)
        }
        viewController.isAddingNewReminder = true
        viewController.isEditing = true
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(didCancelAdd(_:)))
        viewController.navigationItem.title = NSLocalizedString(
            "Add Reminder", comment: "Add Reminder view controller title")
        let navigationController = UINavigationController(rootViewController: viewController)
        /// Modality is a useful design technique you can use to help a user focus on a self-contained task that interrupts their current task, such as when they create a new reminder. You’ll present the navigation controller that you just created as a modal view over the list view.
        present(navigationController, animated: true)
    }
    
    @objc func didCancelAdd(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc func didChangeListStyle(_ sender: UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue: sender.selectedSegmentIndex) ?? .today
        updateSnapshot()
        refreshBackground()
    }
}
