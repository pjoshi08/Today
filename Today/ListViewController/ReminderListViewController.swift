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
        
        updateSnapshot()
        
        collectionView.dataSource = dataSource
    }

    private func listLayout() -> UICollectionViewCompositionalLayout {
        /// creates a new list configuration variable with the grouped appearance.
        /// UICollectionLayoutListConfiguration creates a section in a list layout.
        var listConfiguation = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguation.showsSeparators = false
        listConfiguation.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguation)
    }
}

