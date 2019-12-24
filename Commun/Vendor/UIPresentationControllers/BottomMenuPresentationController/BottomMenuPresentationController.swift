//
//  BottomMenuPresentationController.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class BottomMenuPresentationController: FittingSizePresentationController {
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
}
