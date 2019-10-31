//
//  UIView+Loading.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import ASSpinnerView

let errorViewTag    = 99991

extension UIView {
    func showErrorView(target: Any?, action: Selector) {
        // prevent dupplicated
        if self.viewWithTag(errorViewTag) != nil {return}
        
        // setup new errorView
        let errorView = UIView(frame: frame)
        errorView.tag = errorViewTag
        errorView.backgroundColor = .white
        addSubview(errorView)
        bringSubviewToFront(errorView)
        
        // label
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "there is an error occurred".localized().uppercaseFirst + "\n" + "tap to try again".localized().uppercaseFirst
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(label)
        
        // constraint for label
        label.centerXAnchor.constraint(equalTo: errorView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: errorView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -16).isActive = true
        
        // action for label
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: target, action: action)
        label.addGestureRecognizer(tap)
    }
    
    func hideErrorView() {
        viewWithTag(errorViewTag)?.removeFromSuperview()
    }
    
    func showLoading(cover: Bool = true) {
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
        let size = height > 76 ? 60: height-16
        let spinnerView = ASSpinnerView()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.spinnerLineWidth = size/10
        spinnerView.spinnerDuration = 0.3
        spinnerView.spinnerStrokeColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1)
        coverView.addSubview(spinnerView)
        
        // add constraint for spinnerView
        spinnerView.centerXAnchor.constraint(equalTo: coverView.centerXAnchor, constant: 0).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: coverView.centerYAnchor, constant: 0).isActive = true
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
    
    func removeConstraintToSuperView(withAttribute attribute: NSLayoutConstraint.Attribute)
    {
        guard let superview = superview else {return}
        if let constraint = superview.constraints.first(where: {(($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self) && $0.firstAttribute == attribute})
        {
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
    
        
    var heightConstraint: NSLayoutConstraint? {
        return constraints.first(where: {$0.firstAttribute == .height && $0.secondItem == nil})
    }

}
