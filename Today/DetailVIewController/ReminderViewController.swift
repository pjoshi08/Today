//
//  ReminderViewController.swift
//  Today
//
//  Created by Parth Joshi on 12/9/23.
//

import UIKit

class ReminderViewController: UICollectionViewController {
    /// Data sources are generic. By specifying Int and Row generic parameters, you instruct the compiler that your data source uses instances of Int for the section numbers and instances of Row—the custom enumeration that you defined in the previous section—for the list rows.
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, Row>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<Int, Row>
    
    var reminder: Reminder
    private var dataSource: DataSource!
    
    init(reminder: Reminder) {
        self.reminder = reminder
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
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
        
        updateSnapshot()
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        var contentConfiguration = cell.defaultContentConfiguration()
        /// Supply the data using the text(for:) function, and provide the font styling using the rows’ textStyle computed variable
        contentConfiguration.text = text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        cell.contentConfiguration = contentConfiguration
        cell.tintColor = .todayPrimaryTint
    }
    
    func text(for row: Row) -> String? {
        switch row {
        case .date: return reminder.dueDate.dayText
        case .notes: return reminder.notes
        case .time: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        case .title: return reminder.title
        }
    }
    
    private func updateSnapshot() {
        var snapshot = SnapShot()
        snapshot.appendSections([0])
        snapshot.appendItems([Row.title, Row.date, Row.time, Row.notes], toSection: 0)
        /// applying a snapshot updates the user interface to reflect the snapshot’s data and styling.
        dataSource.apply(snapshot)
    }
}
