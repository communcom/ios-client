//
//  UIButton+Extensions.swift
//  golos-ios
//
//  Created by Grigory Serebryanyy on 13/01/2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//

import UIKit

private var pTouchAreaEdgeInsets: UIEdgeInsets = .zero

extension UIButton {
    /// hexColors: [normal, highlighted, selected, disabled]
    public func tune(withTitle title: String,
                     textColor: UIColor?,
                     font: UIFont?,
                     alignment: NSTextAlignment) {
        self.titleLabel?.font = font
        self.titleLabel?.textAlignment = alignment
        self.contentMode = .scaleAspectFill
        self.backgroundColor = backgroundColor
        if let textColor = textColor {
            self.setTitleColor(textColor, for: .normal)
        }
        self.setTitle(title.localized(), for: .normal)
    }

    // MARK: - expansion of the touch area
    public var touchAreaEdgeInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &pTouchAreaEdgeInsets) as? NSValue {
                var edgeInsets: UIEdgeInsets = .zero
                value.getValue(&edgeInsets)
                return edgeInsets
            } else {
                return .zero
            }
        }
        set(newValue) {
            var newValueCopy = newValue
            let objCType = NSValue(uiEdgeInsets: .zero).objCType
            let value = NSValue(&newValueCopy, withObjCType: objCType)
            objc_setAssociatedObject(self, &pTouchAreaEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.touchAreaEdgeInsets == .zero || !self.isEnabled || self.isHidden {
            return super.point(inside: point, with: event)
        }

        let relativeFrame = self.bounds
        let hitFrame = relativeFrame.inset(by: self.touchAreaEdgeInsets)

        return hitFrame.contains(point)
    }

}
