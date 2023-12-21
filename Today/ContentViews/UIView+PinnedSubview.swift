//
//  UIView+PinnedSubview.swift
//  Today
//
//  Created by Parth Joshi on 12/17/23.
//

import UIKit

extension UIView {
    /// Because each control uses a similar layout, you’ll extend the capabilities of a view to add a subview that is pinned to its superview with optional padding.
    func addPinnedSubview(
        _ subview: UIView, height: CGFloat? = nil,
        insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    ) {
        /// The addsubview(_:) method of UIView adds the subview to the bottom of the superview’s hierarchy.
        addSubview(subview)
        /// The system automatically generates constraints based on a view’s current size and position. But those constraints don’t allow the view to adapt.
        /// to prevent the system from creating automatic constraints for this view.
        /// You’ll provide constraints that dynamically lay out the view for any size or orientation.
        subview.translatesAutoresizingMaskIntoConstraints = false
        /// Pin the subview to the top of the superview by adding and activating a top anchor constraint.
        subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        /// Auto Layout determines a view’s neighbors along the horizontal axis using leading and trailing instead of left and right. This approach allows Auto Layout to automatically correct a view’s appearance in both right-to-left and left-to-right languages
        subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        /// Add padding to the trailing edge of the subview by specifying and activating a trailing anchor constraint.
        subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.0 * insets.right)
            .isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0 * insets.bottom)
            .isActive = true
        /// If the caller explicitly provides a height to the function, constrain the subview to that height.
        /// Because the subview is pinned to the top and bottom of the superview, adjusting the height of the subview forces the superview to also adjust its height.
        if let height {
            subview.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
