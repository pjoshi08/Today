//
//  ReminderViewController+Row.swift
//  Today
//
//  Created by Parth Joshi on 12/9/23.
//

import UIKit

extension ReminderViewController {
    /// Later, you’ll use instances of Row to represent items in the detail list. Diffable data sources that supply UIKit lists with data and styling require that items conform to Hashable. The diffable data source uses hash values to determine which elements have changed between snapshots.
    enum Row: Hashable {
        case date
        case notes
        case time
        case title
        
        var imageName: String? {
            switch self {
            case .date: return "calender.circle"
            case .notes: return "square.and.pencil"
            case .time: return "clock"
            default: return nil
            }
        }
        
        var image: UIImage? {
            guard let imageName = imageName else { return nil }
            let configuration = UIImage.SymbolConfiguration(textStyle: .headline)
            return UIImage(systemName: imageName, withConfiguration: configuration)
        }
        
        var textStyle: UIFont.TextStyle {
            switch self {
            case .title: return .headline
            default: return .subheadline
            }
        }
    }
}
