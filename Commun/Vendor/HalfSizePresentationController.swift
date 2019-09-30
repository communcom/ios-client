//
//  HalfSizePresentationController.swift
//  Commun
//
//  Created by Chung Tran on 9/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class HalfSizePresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {return .zero}
        let height: CGFloat = containerView.bounds.height * 2 / 3
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }
}
