//
//  TextViewContentView.swift
//  Today
//
//  Created by Parth Joshi on 12/21/23.
//

import UIKit

class TextViewContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {
        var text: String? = ""
        var onChange: (String) -> Void = { _ in }
        
        func makeContentView() -> UIView & UIContentView {
            return TextViewContentView(self)
        }
    }
    
    let textView = UITextView()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        /// Text views are scroll views. Even though you assign a fixed height to the text view, the scroll view accommodates users with automatic scrolling and scroll indicators if they enter more text than can fit.
        addPinnedSubview(textView, height: 200)
        textView.backgroundColor = nil
        /// You’re assigning this content view to be the delegate of the text view control. As such, it monitors the text view control for user interactions and responds accordingly.
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textView.text = configuration.text
    }
}

extension UICollectionViewListCell {
    func textViewConfiguration() -> TextViewContentView.Configuration {
        TextViewContentView.Configuration()
    }
}

/// You’ll assign a helper object, or delegate, for the text view. Objects that you assign as a text view delegate and that conform to the UITextViewDelegate protocol can intervene when the text view detects a user interaction.
extension TextViewContentView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let configuration = configuration as? TextViewContentView.Configuration else { return }
        configuration.onChange(textView.text)
    }
}
