//
//  TransferHistoryFilterVC.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class TransferHistoryFilterVC: BottomMenuVC {
    override func setUp() {
        super.setUp()
        title = "filter".localized().uppercaseFirst
        
        titleLabel.autoPinEdge(toSuperviewEdge: .bottom)
    }
}
