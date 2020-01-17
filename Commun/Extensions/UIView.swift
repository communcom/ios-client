//
//  UIView+Loading.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import ASSpinnerView

extension UIView {
    func showErrorView(retryAction: (() -> Void)?) {
        // setup new errorView
        let errorView = ErrorView(retryAction: retryAction)
        
        // add subview
        addSubview(errorView)
        errorView.autoPinEdgesToSuperviewEdges()
        
    }
    
    func showForceUpdate() {
        // setup new errorView
        let errorView = ForceUpdateView()
        
        // add subview
        addSubview(errorView)
        errorView.autoPinEdgesToSuperviewEdges()
    }
    
    func hideErrorView() {
        subviews.forEach { (view) in
            if view is ErrorView {
                view.removeFromSuperview()
            }
        }
    }
    
    var isLoading: Bool {
        self.viewWithTag(9999) != nil
    }
    
    func showLoading(cover: Bool = true, spinnerColor: UIColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1), size: CGFloat? = nil, centerYOffset: CGFloat? = nil) {
        // if loading view is existed
        if self.viewWithTag(9999) != nil {return}
        
        // create cover view to cover all current view
        let coverView = UIView()
        coverView.backgroundColor = cover ? .white : .clear
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.tag = 9999
        self.addSubview(coverView)
        
        // add constraint for coverView
        coverView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        coverView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        coverView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0).isActive = true
        coverView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0).isActive = true
        self.bringSubviewToFront(coverView)
        
        // add spinnerView
        let size = size ?? (height > 76 ? 60: height-16)
        let spinnerView = ASSpinnerView()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.spinnerLineWidth = size/10
        spinnerView.spinnerDuration = 0.3
        spinnerView.spinnerStrokeColor = spinnerColor.cgColor
        coverView.addSubview(spinnerView)
        
        // add constraint for spinnerView
        spinnerView.centerXAnchor.constraint(equalTo: coverView.centerXAnchor, constant: 0).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: coverView.centerYAnchor, constant: centerYOffset ?? 0).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: size).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    func hideLoading() {
        self.viewWithTag(9999)?.removeFromSuperview()
    }
    
    func shake() {
        let midX = center.x
        let midY = center.y
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        
        animation.fromValue = CGPoint(x: midX-30, y: midY)
        animation.toValue = CGPoint(x: midX+30, y: midY)
        
        layer.add(animation, forKey: "position")
    }
    
    func removeConstraintToSuperView(withAttribute attribute: NSLayoutConstraint.Attribute) {
        guard let superview = superview else {return}
        if let constraint = superview.constraints.first(where: {(($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self) && $0.firstAttribute == attribute}) {
            superview.removeConstraint(constraint)
        }
    }
    
    public func removeAllConstraints() {
        var _superview = self.superview

        while let superview = _superview {
            for constraint in superview.constraints {

                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }

        self.removeConstraints(self.constraints)
    }
    
    var topConstraint: NSLayoutConstraint? {
        return constraints.first(where: {$0.firstAttribute == .top})
    }
        
    var heightConstraint: NSLayoutConstraint? {
        return constraints.first(where: {$0.firstAttribute == .height && $0.secondItem == nil})
    }
    
    var leftConstraint: NSLayoutConstraint? {
        return superview?.constraints.first(where: {$0.firstAttribute == .leading && (($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self)})
    }

    var widthConstraint: NSLayoutConstraint? {
        return constraints.first(where: {$0.firstAttribute == .width && $0.secondItem == nil})
    }
    
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.cornerRadius = radius
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }
}
