//
//  ProgressHeaderView.swift
//  Today
//
//  Created by Parth Joshi on 1/3/24.
//

import UIKit

/// Instead of deleting views when a user scrolls them out of the visible bounds, the UICollectionReusableView class keeps views in the reuse queue. You can use UICollectionReusableView to create supplementary views. Supplementary views are separate from the individual collection view cells, so they are ideal for creating headers or footers.
class ProgressHeaderView: UICollectionReusableView {
    /// The element kind specifies a type of supplementary view that the collection view can present.
    static var elementKind: String { UICollectionView.elementKindSectionHeader }
    
    /// CGFloat represents floating-point scalar values. The CG prefix prepends objects from the Core Graphics framework, which is a drawing engine.
    var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            heightConstraint?.constant = progress * bounds.height
            UIView.animate(withDuration: 0.2) { [weak self] in
                /// The layoutIfNeeded() method forces the view to update its layout immediately by animating the height changes of the upper and lower views.
                self?.layoutIfNeeded()
            }
        }
    }
    
    private let upperView = UIView(frame: .zero)
    private let lowerView = UIView(frame: .zero)
    private let containerView = UIView(frame: .zero)
    private var heightConstraint: NSLayoutConstraint?
    private var valueFormat: String {
        NSLocalizedString("%d percent", comment: "progress percent value format")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareSubviews()
        
        /// isAccessibilityElement indicates whether the element is an accessibility element that an assistive technology can access. Standard UIKit controls enable this value by default.
        isAccessibilityElement = true
        accessibilityLabel = NSLocalizedString("Progress", comment: "progress view accessibility label")
        /// VoiceOver reads that the progress view updates frequently to signal to users that they may want to return to this view.
        accessibilityTraits.update(with: .updatesFrequently)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Your view uses its corner radius to create the appearance of a circle. You’ll customize the view’s layout behavior so that you can adjust the corner radius whenever the size changes.
    override func layoutSubviews() {
        super.layoutSubviews()
        accessibilityValue = String(format: valueFormat, Int(progress * 100.0))
        heightConstraint?.constant = progress * bounds.height
        /// Core Animation applies a clipping mask to the CGRect frame that shapes the container view into a circle.
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.5 * containerView.bounds.width
    }
    
    private func prepareSubviews() {
        containerView.addSubview(upperView)
        containerView.addSubview(lowerView)
        addSubview(containerView)
        
        /// Disable translatesAutoresizingMaskIntoConstraints for the subviews so that you can modify the constraints for the subviews.
        /// When true, the system automatically specifies a view’s size and position.
        upperView.translatesAutoresizingMaskIntoConstraints = false
        lowerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        /// assigning true to isActive adds the constraint to the common ancestor in the view hierarchy and activates it.
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        /// These constraints set a fixed aspect ratio for the superview and container view by equating the height anchors to the width anchors.
        containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1)
            .isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        /// You need to set the multiplier for only one axis because you already set a fixed aspect ratio for the container view.
        containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85).isActive = true
        
        upperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        upperView.bottomAnchor.constraint(equalTo: lowerView.topAnchor).isActive = true
        lowerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        upperView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        upperView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lowerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lowerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        /// This constraint increases the lower view’s height to reflect a user’s progress in completing reminders. As this constraint increases, the height of the upper view decreases because the heights are inversely proportional.
        heightConstraint = lowerView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        upperView.backgroundColor = .todayProgressUpperBackground
        lowerView.backgroundColor = .todayProgressLowerBackground
    }
}
