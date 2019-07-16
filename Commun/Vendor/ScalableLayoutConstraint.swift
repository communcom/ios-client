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
        
        switch firstAttribute {
        case .leading, .trailing, .left, .right, .width:
            constant *= Config.widthRatio
        case .top, .bottom, .height:
            constant *= Config.heightRatio
        default:
            return
        }
    }
}

#endif
