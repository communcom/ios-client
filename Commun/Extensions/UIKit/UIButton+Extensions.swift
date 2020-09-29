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
    
    static var changeCoverButton: UIButton {
        let button = UIButton(width: 24, height: 24, backgroundColor: UIColor.black.withAlphaComponent(0.3), cornerRadius: 12, contentInsets: UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        button.tintColor = .white
        button.setImage(UIImage(named: "photo_solid")!, for: .normal)
        return button
    }
    
    static var changeAvatarButton: UIButton {
        let button = UIButton(width: 20, height: 20, backgroundColor: .appLightGrayColor, cornerRadius: 10, contentInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        button.tintColor = .appGrayColor
        button.setImage(UIImage(named: "photo_solid")!, for: .normal)
        button.borderColor = UIColor.appWhiteColor.inDarkMode(.appLightGrayColor)
        button.borderWidth = 2
        return button
    }
    
    static var clearButton: UIButton {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        btnView.setImage(UIImage(named: "icon-cancel-grey-cyrcle-default"), for: .normal)
        btnView.imageEdgeInsets = .zero
        return btnView
    }
}
