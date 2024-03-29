//
//  TextFieldContentView.swift
//  Today
//
//  Created by Parth Joshi on 12/20/23.
//

import UIKit

/// Adopting UIContentView protocol signals that this view renders the content and styling that you define within a configuration. The content view’s configuration provides values for all supported properties and behaviors to customize the view.
class TextFieldContentView: UIView, UIContentView {
    /// You’ll use the TextFieldContentView.Configuration type to customize the content of your configuration and your view.
    struct Configuration: UIContentConfiguration {
        var text: String? = ""
        var onChange: (String) -> Void = { _ in }
        
        /// a function named makeContentView() that returns a UIView that conforms to the UIContentView protocol.
        /// The initializer for TextFieldContentView takes a UIContentConfiguration. This UIContentConfiguration, however, has a string that represents the content packaged inside the text field.
        func makeContentView() -> UIView & UIContentView {
            return TextFieldContentView(self)
        }
    }
    
    let textField = UITextField()
    var configuration: UIContentConfiguration {
        /// Whenever the configuration changes, you’ll update the user interface to reflect the current state.
        didSet {
            configure(configuration: configuration)
        }
    }
    
    /// Setting this property allows a custom view to communicate its preferred size to the layout system.
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        /// to pin the text field, and then provide horizontal padding insets.
        /// The text field is pinned to the top of the superview and has a horizontal padding of 16. Top and bottom insets of 0 force the text field to span the entire height of the superview.
        addPinnedSubview(textField, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        /// By adding a target and action to this view, the view calls the target’s didChange(_:) selector whenever the control detects a user interaction. In this case, you invoke the method whenever a user changes the text in the field.
        /// You can choose to invoke the action when the user first taps the control, when they begin editing, when they end editing, or whenever they interact with the control.
        textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
        textField.clearButtonMode = .whileEditing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        /// The input to this configuration must have a text property associated with it so that you can set it to the content of the text field.
        guard let configuration = configuration as? Configuration else { return }
        textField.text = configuration.text
    }
    
    /// use the @objc attribute to make a property or method available to Objective-C code.
    @objc private func didChange(_ sender: UITextField) {
        guard let configuration = configuration as? TextFieldContentView.Configuration else { return }
        configuration.onChange(textField.text ?? "")
    }
}

/// This is to return a custom configuration that we'll pair with the custom TextFieldContentView.
extension UICollectionViewListCell {
    func textFieldConfiguration() -> TextFieldContentView.Configuration {
        TextFieldContentView.Configuration()
    }
}
