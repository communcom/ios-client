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
    lazy var typeSegmentedControl = CMTopTabBar(height: 50, labels: ["transfer".localized().uppercaseFirst, "convert".localized().uppercaseFirst], selectedIndex: 0)
    lazy var rewardsSegmentedControl = CMTopTabBar(height: 50, labels: ["post".localized().uppercaseFirst, "like".localized().uppercaseFirst, "comment".localized().uppercaseFirst], selectedIndex: 0)
    
    override func setUp() {
        super.setUp()
        title = "filter".localized().uppercaseFirst
        
        segmentedControl.labels = ["all".localized().uppercaseFirst, "income".localized().uppercaseFirst, "outcome".localized().uppercaseFirst]
        segmentedControl.selectedIndex = 0
        
        view.addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.top, to: .bottom, of: closeButton, withOffset: 24 * Config.heightRatio)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.widthRatio)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.widthRatio)
        
        // type
        let typeLabel = UILabel.with(text: "type".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .a5a7bd)
        view.addSubview(typeLabel)
        typeLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.widthRatio)
        typeLabel.autoPinEdge(.top, to: .bottom, of: segmentedControl, withOffset: 30 * Config.heightRatio)
        
        view.addSubview(typeSegmentedControl)
        typeSegmentedControl.autoPinEdge(.top, to: .bottom, of: typeLabel, withOffset: 20 * Config.heightRatio)
        typeSegmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.widthRatio)
        typeSegmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.widthRatio)
        
        // reward
        let rewardsLabel = UILabel.with(text: "rewards".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .a5a7bd)
        view.addSubview(rewardsLabel)
        rewardsLabel.autoPinEdge(.top, to: .bottom, of: typeSegmentedControl, withOffset: 30 * Config.heightRatio)
        rewardsLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.widthRatio)
        
        view.addSubview(rewardsSegmentedControl)
        rewardsSegmentedControl.autoPinEdge(.top, to: .bottom, of: rewardsLabel, withOffset: 20 * Config.heightRatio)
        rewardsSegmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.widthRatio)
        rewardsSegmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.widthRatio)
        
        rewardsSegmentedControl.autoPinEdge(toSuperviewEdge: .bottom)
    }
}
