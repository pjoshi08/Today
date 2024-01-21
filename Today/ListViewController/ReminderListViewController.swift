//
//  ViewController.swift
//  Today
//
//  Created by Parth Joshi on 12/1/23.
//

import UIKit

class ReminderListViewController: UICollectionViewController {
    
    var dataSource: DataSource!
    var reminders: [Reminder] = []
    var listStyle: ReminderListStyle = .today
    var filteredReminders: [Reminder] {
        return reminders.filter { listStyle.shouldInclude(date: $0.dueDate) }.sorted {
            $0.dueDate < $1.dueDate
        }
    }
    let listStyleSegmentedControl = UISegmentedControl(items: [
        ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name
    ])
    var headerView: ProgressHeaderView?
    var progress: CGFloat {
        let chunkSize = 1.0 / CGFloat(filteredReminders.count)
        let progress = filteredReminders.reduce(0.0) {
            let chunk = $1.isComplete ? chunkSize : 0
            return $0 + chunk
        }
        return progress
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .todayGradientFutureBegin
        
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        /// Cell registration specifies how to configure the content and appearance of a cell.
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        /// Register the headerview as a supplementary view
        let headerRegistration = UICollectionView.SupplementaryRegistration(
            elementKind: ProgressHeaderView.elementKind, handler: supplementaryRegistrationHandler)
        /// After registering the supplementary view, you need to pass the registration in a method that dequeues a reusable supplementary view object
        /// This closure configures and returns the supplementary header view from the diffable data source.
        dataSource.supplementaryViewProvider = { supplementaryView, elementKind, indexPath in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: indexPath)
        }
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString(
            "Add reminder", comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
        
        listStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue
        listStyleSegmentedControl.addTarget(
            self, action: #selector(didChangeListStyle(_:)), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentedControl
        
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
        
        updateSnapshot()
        
        collectionView.dataSource = dataSource
        
        prepareReminderStore()
    }
    
    override func collectionView(
        _ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let id = filteredReminders[indexPath.item].id
        pushDetailViewForReminder(withId: id)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshBackground()
    }
    
    /// The system calls this method when the collection view is about to display the supplementary view.
    override func collectionView(
        _ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String, at indexPath: IndexPath
    ) {
        guard elementKind == ProgressHeaderView.elementKind,
              let progressView = view as? ProgressHeaderView else { return }
        progressView.progress = progress
    }
    
    func refreshBackground() {
        collectionView.backgroundView = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradientLayer(for: listStyle, in: collectionView.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        collectionView.backgroundView = backgroundView
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
    
    func showError(_ error: Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error alert title")
        let alert = UIAlertController(
            title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK", comment: "Alert OK button title")
        alert.addAction(
            UIAlertAction(
                title: actionTitle, style: .default,
                handler: { [weak self] _ in
                    self?.dismiss(animated: true)
                }))
        present(alert, animated: true, completion: nil)
    }

    private func listLayout() -> UICollectionViewCompositionalLayout {
        /// creates a new list configuration variable with the grouped appearance.
        /// UICollectionLayoutListConfiguration creates a section in a list layout.
        var listConfiguation = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguation.headerMode = .supplementary
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
    
    private func supplementaryRegistrationHandler(
        progressView: ProgressHeaderView, elementKind: String, indexPath: IndexPath
    ) {
        headerView = progressView
    }
}

