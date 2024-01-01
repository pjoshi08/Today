//
//  ViewController.swift
//  Today
//
//  Created by Parth Joshi on 12/1/23.
//

import UIKit

class ReminderListViewController: UICollectionViewController {
    
    var dataSource: DataSource!
    var reminders: [Reminder] = Reminder.sampleData

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        /// Cell registration specifies how to configure the content and appearance of a cell.
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString(
            "Add reminder", comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
        
        updateSnapshot()
        
        collectionView.dataSource = dataSource
    }
    
    override func collectionView(
        _ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let id = reminders[indexPath.item].id
        pushDetailViewForReminder(withId: id)
        return false
    }
    
    func pushDetailViewForReminder(withId id: Reminder.ID) {
        let reminder = reminder(withId: id)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            /// This function updates the array of reminders in the data source with the edited reminder.
            self?.updateReminder(reminder)
            /// Because updating the snapshot depends on the array of reminders, you must update the array of reminders before you update the snapshot.
            self?.updateSnapshot(reloading: [reminder.id])
        }
        /// If a view controller is currently embedded in a navigation controller, a reference to the navigation controller is stored in the optional navigationController property.
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func listLayout() -> UICollectionViewCompositionalLayout {
        /// creates a new list configuration variable with the grouped appearance.
        /// UICollectionLayoutListConfiguration creates a section in a list layout.
        var listConfiguation = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguation.showsSeparators = false
        listConfiguation.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguation.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguation)
    }
    
    /// A UISwipeActionsConfiguration object associates custom swipe actions with a row in a list. You’ll create a function that generates a configuration for each item in the list.
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        /// By default, destructive actions appear with a red background. You can customize an action’s background by setting the background property.
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) {
            [weak self] _, _, completion in
            self?.deleteReminder(withId: id)
            self?.updateSnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

