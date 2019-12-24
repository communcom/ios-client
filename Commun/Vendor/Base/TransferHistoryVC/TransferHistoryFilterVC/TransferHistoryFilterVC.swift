//
//  TransferHistoryFilterVC.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class TransferHistoryFilterVC: BottomMenuVC {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var segmentedControl = TransferHistorySegmentedControl(height: 60 * Config.heightRatio)
    
    override func setUp() {
        super.setUp()
        title = "filter".localized().uppercaseFirst
        
        segmentedControl.labels = ["all".localized().uppercaseFirst, "income".localized().uppercaseFirst, "outcome".localized().uppercaseFirst]
        segmentedControl.selectedIndex = 0
        
        view.addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.top, to: .bottom, of: closeButton, withOffset: 24 * Config.heightRatio)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.heightRatio)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.heightRatio)
        
        segmentedControl.autoPinEdge(toSuperviewEdge: .bottom)
    }
}
