//
//  PaddingLayoutConstraint.swift
//  Commun
//
//  Created by Chung Tran on 17/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

#if !os(tvOS)
@available(tvOS, unavailable)
class ScalableLayoutConstraint: NSLayoutConstraint {
    @available(tvOS, unavailable)
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let oldConstant = constant
        
        switch firstAttribute {
        case .leading, .trailing, .left, .right, .width:
            constant *= Config.widthRatio
        case .top, .bottom, .height:
            constant *= Config.heightRatio
        default:
            return
        }
        
        if let view = firstItem as? UIView {
            view.layer.cornerRadius = view.layer.cornerRadius * constant / oldConstant
        }
    }
}

#endif
