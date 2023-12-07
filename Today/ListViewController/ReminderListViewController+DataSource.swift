//
//  ReminderListViewController+DataSource.swift
//  Today
//
//  Created by Parth Joshi on 12/5/23.
//

import UIKit

extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Int, String>
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: String) {
        let reminder = Reminder.sampleData[indexPath.item]
        var contentConfiguration = cell.defaultContentConfiguration()
        /// The list displays the configuration text as the primary text of a cell.
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(
            forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration
        
        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
        /// You can create colors several ways: by providing red, green, and blue components; by providing hue, saturation, and brightness values; or by providing a single white value for grayscale colors. Try using these UIColor initializers to create other button tint colors. If you need help, refer to the Color creation docs.
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration), .disclosureIndicator(displayed: .always)
        ]
        
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        /// backgroundConfiguration.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.9, alpha: 1.0)
        backgroundConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroundConfiguration
    }
    
    private func doneButtonConfiguration(for reminder: Reminder) 
    -> UICellAccessory.CustomViewConfiguration 
    {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = UIButton()
        /// You can configure a UIButton object to display one image when it’s in its normal state and a different image when it’s highlighted.
        button.setImage(image, for: .normal)
        /// You’ll add a done button cell accessory to the leading side of the reminder cell. You can also add checkmark, reorder, delete, and disclosure-indicator cell accessories to a list cell.
        return UICellAccessory.CustomViewConfiguration(
            customView: button, placement: .leading(displayed: .always))
    }
}
