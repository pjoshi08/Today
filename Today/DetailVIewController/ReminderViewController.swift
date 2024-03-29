//
//  ReminderViewController.swift
//  Today
//
//  Created by Parth Joshi on 12/9/23.
//

import UIKit

class ReminderViewController: UICollectionViewController {
    /// Data sources are generic. By specifying Int and Row generic parameters, you instruct the compiler that your data source uses instances of Int for the section numbers and instances of Row—the custom enumeration that you defined in the previous section—for the list rows.
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<Section, Row>
    
    var reminder: Reminder {
        didSet {
            onChange(reminder)
        }
    }
    var workingReminder: Reminder
    var isAddingNewReminder = false
    var onChange: (Reminder) -> Void
    private var dataSource: DataSource!
    
    /// Recall that when you pass a closure as an argument, you need to label it as escaping if it’s called after the function returns.
    init(reminder: Reminder, onChange: @escaping (Reminder) -> Void) {
        self.reminder = reminder
        self.workingReminder = reminder
        self.onChange = onChange
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        /// [Display Headers](https://developer.apple.com/documentation/uikit/uicollectionview)
        listConfiguration.headerMode = .firstItemInSection
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        /// Class inheritance and initialization: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization/#Class-Inheritance-and-Initialization
        /// Swift subclass must call one of its superclass’s designated initializers during initialization.
        super.init(collectionViewLayout: listLayout)
    }
    
    /// Interface Builder stores archives of the view controllers you create. A view controller requires an init(coder:) initializer so the system can initialize it using such an archive. If the view controller can’t be decoded and constructed, the initialization fails. When constructing an object using a failable initializer, the result is an optional that contains either the initialized object if it succeeds or nil if the initialization fails.
    required init?(coder: NSCoder) {
        fatalError("Always initialized ReminderViewController using init(reminder:)")
    }
    
    /// You’ll intervene in the view controller’s life cycle to register the cell with the collection view and create the data source after the view loads.
    override func viewDidLoad() {
        /// give the superclass a chance to perform its own tasks prior to your custom tasks.
        super.viewDidLoad()
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Row) in
            // recycle cells as they go offscreen
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        if #available(iOS 16, *) {
            /// The .navigator style places the title in the center horizontally and includes a back button on the left.
            /// Additional navigation item styles are available. The .editor style places a customized toolset in the center of the bar for apps that support editing individual documents. The .browser style formats the bar to support a navigation view history or tree structure on the leading edge.
            navigationItem.style = .navigator
        }
        navigationItem.title = NSLocalizedString("Reminder", comment: "Reminder view controller title")
        navigationItem.rightBarButtonItem = editButtonItem
        
        updateSnapshotForViewing()
    }
    
    /// The system calls setEditing(_:animated:) when the user taps the Edit or Done button. You’ll override this method to update ReminderViewController for the view and editing modes.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            prepareForEditing()
        } else {
            if isAddingNewReminder {
                onChange(workingReminder)
            } else {
                prepareForViewing()
            }
        }
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let section = section(for: indexPath)
        /// switch statement using a tuple to configure cells for different section and row combinations
        switch (section, row) {
        /// a case that matches a header row, and store the header row’s associated String value in a constant named title
        case (_, .header(let title)):
            cell.contentConfiguration = headerConfiguration(for: cell, with: title)
        /// Add a case that matches all rows in the .view section.
        case (.view, _):
            cell.contentConfiguration = defaultConfiguration(for: cell, at: row)
        case (.title, .editableText(let title)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: title)
        case (.date, .editableDate(let date)):
            cell.contentConfiguration = dateConfiguration(for: cell, with: date)
        case (.notes, .editableText(let notes)):
            cell.contentConfiguration = notesConfiguration(for: cell, with: notes)
        default:
            fatalError("Unexpected combination of section and row.")
        }
        
        cell.tintColor = .todayPrimaryTint
    }
    
    @objc func didCancelEdit() {
        workingReminder = reminder
        setEditing(false, animated: true)
    }
    
    private func prepareForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(didCancelEdit))
        updateSnapshotForEditing()
    }
    
    private func updateSnapshotForEditing() {
        var snapshot = SnapShot()
        snapshot.appendSections([.title, .date, .notes])
        snapshot.appendItems(
            [.header(Section.title.name), .editableText(reminder.title)], toSection: .title)
        snapshot.appendItems(
            [.header(Section.date.name), .editableDate(reminder.dueDate)], toSection: .date)
        snapshot.appendItems(
            [.header(Section.notes.name), .editableText(reminder.notes)], toSection: .notes)
        dataSource.apply(snapshot)
    }
    
    private func prepareForViewing() {
        navigationItem.leftBarButtonItem = nil
        if workingReminder != reminder {
            reminder = workingReminder
        }
        updateSnapshotForViewing()
    }
    
    private func updateSnapshotForViewing() {
        var snapshot = SnapShot()
        snapshot.appendSections([.view])
        snapshot.appendItems([Row.header(""), Row.title, Row.date, Row.time, Row.notes], toSection: .view)
        /// applying a snapshot updates the user interface to reflect the snapshot’s data and styling.
        dataSource.apply(snapshot)
    }
    
    private func section(for indexPath: IndexPath) -> Section {
        /// In view mode, all items are displayed in section 0. In editing mode, the title, date, and notes are separated into sections 1, 2, and 3, respectively.
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        /// Swift enumerations defined with a raw value have a failable initializer that returns nil if the provided raw value is outside the defined range.
        guard let section = Section(rawValue: sectionNumber) else {
            fatalError("Unable to find matchin section")
        }
        return section
    }
}
