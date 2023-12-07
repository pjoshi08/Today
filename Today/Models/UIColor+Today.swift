//
//  UIColor+Today.swift
//  Today
//
//  Created by Parth Joshi on 12/4/23.
//

import UIKit

extension UIColor {
    static var TodayDetailCellTint: UIColor {
        UIColor(named: "TodayDetailCellTint") ?? .tintColor
    }
    
    static var TodayListCellBackground: UIColor {
        UIColor(named: "TodayListCellBackground") ?? .secondarySystemBackground
    }
    
    static var TodayListCellDoneButtonTint: UIColor {
        UIColor(named: "TodayListCellDoneButtonTint") ?? .tintColor
    }
    
    static var TodayGradientAllBegin: UIColor {
        UIColor(named: "TodayGradientAllBegin") ?? .systemFill
    }
    
    static var TodayGradientAllEnd: UIColor {
        UIColor(named: "TodayGradientAllEnd") ?? .quaternarySystemFill
    }
    
    static var TodayGradientFutureBegin: UIColor {
        UIColor(named: "TodayGradientFutureBegin") ?? .systemFill
    }
    
    static var TodayGradientFutureEnd: UIColor {
        UIColor(named: "TodayGradientFutureEnd") ?? .quaternarySystemFill
    }
    
    static var TodayGradientTodayBegin: UIColor {
        UIColor(named: "TodayGradientTodayBegin") ?? .systemFill
    }
    
    static var TodayGradientTodayEnd: UIColor {
        UIColor(named: "TodayGradientTodayEnd") ?? .quaternarySystemFill
    }
    
    static var TodayNavigationBackground: UIColor {
        UIColor(named: "TodayNavigationBackground") ?? .secondarySystemBackground
    }
    
    static var TodayPrimaryTint: UIColor {
        UIColor(named: "TodayPrimaryTint") ?? .tintColor
    }
    
    static var TodayProgressLowerBackground: UIColor {
        UIColor(named: "TodayProgressLowerBackground") ?? .systemGray
    }
    
    static var TodayProgressUpperBackground: UIColor {
        UIColor(named: "TodayProgressUpperBackground") ?? .systemGray6
    }
}
