//
//  UIContentConfiguration+Stateless.swift
//  Today
//
//  Created by Parth Joshi on 12/20/23.
//

import UIKit

/// An object that conforms to UIContentView requires a configuration property of type UIContentConfiguration
/// The configuration that you use in the editable title cell has a text property that represents the value included in the text field
/// The UIContentConfiguration protocol requires conforming types to implement the makeContentView() and updated(for:) methods
extension UIContentConfiguration {
    /// The updated(for:) method allows a UIContentConfiguration to provide a specialized configuration for a given state. In Today, you’ll use the same configuration for all states, including normal, highlighted, and selected.
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
