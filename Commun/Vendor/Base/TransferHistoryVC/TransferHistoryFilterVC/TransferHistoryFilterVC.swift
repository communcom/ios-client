//
//  TransferHistoryFilterVC.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class TransferHistoryFilterVC: BottomMenuVC {
    // MARK: - Properties
    var originFilter: TransferHistoryListFetcher.Filter
    var completion: ((TransferHistoryListFetcher.Filter) -> Void)?
    
    // MARK: - Subviews
    lazy var segmentedControl = TransferHistorySegmentedControl(height: 60 * Config.heightRatio)
    lazy var typeSegmentedControl = TransferHistoryTopTabBar(height: 50, labels: ["transfer".localized().uppercaseFirst, "convert".localized().uppercaseFirst], selectedIndex: 0, spacing: 20 * Config.widthRatio)
    
    // TODO: - Uncomment when filter by rewards is ready
//    lazy var rewardsSegmentedControl = TransferHistoryTopTabBar(height: 50, labels: ["post".localized().uppercaseFirst, "like".localized().uppercaseFirst, "comment".localized().uppercaseFirst], selectedIndex: 0, spacing: 20 * Config.widthRatio)
    lazy var rewardsSegmentedControl = CMTopTabBar(height: 50, labels: ["all".localized().uppercaseFirst, "none".localized().uppercaseFirst], selectedIndex: 0, spacing: 20 * Config.widthRatio)
    
    // MARK: - Initializers
    init(filter: TransferHistoryListFetcher.Filter) {
        self.originFilter = filter
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "filter".localized().uppercaseFirst
        
        segmentedControl.labels = ["all".localized().uppercaseFirst, "income".localized().uppercaseFirst, "outcome".localized().uppercaseFirst]
        
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
        
        // save
        let saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst, isHuggingContent: false)
        view.addSubview(saveButton)
        saveButton.autoPinEdge(.top, to: .bottom, of: rewardsSegmentedControl, withOffset: 40 * Config.heightRatio)
        saveButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.widthRatio)
        saveButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.widthRatio)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        let cleanAllButton = UIButton(height: 50 * Config.heightRatio, label: "clean all".localized().uppercaseFirst, labelFont: UIFont.systemFont(ofSize: 15, weight: .semibold), backgroundColor: .f3f5fa, textColor: .appMainColor, cornerRadius: 50 * Config.heightRatio / 2)
        view.addSubview(cleanAllButton)
        cleanAllButton.autoPinEdge(.top, to: .bottom, of: saveButton, withOffset: 10)
        cleanAllButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.widthRatio)
        cleanAllButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.widthRatio)
        cleanAllButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        
        // pin bottom
        cleanAllButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        // assign first value
        setUp(with: originFilter)
    }
    
    @objc func save() {
        var direction = "all"
        // first filter
        switch segmentedControl.selectedIndex {
        case 1:
            direction = "receive"
        case 2:
            direction = "send"
        default:
            break
        }
        
        var transferType = "all"
        switch typeSegmentedControl.selectedIndex.value {
        case 0:
            transferType = "transfer"
        case 1:
            transferType = "convert"
        default:
            break
        }
        
        var rewards: String?
        switch rewardsSegmentedControl.selectedIndex.value {
        case 0:
            rewards = "all"
        case 1:
            rewards = "none"
        default:
            break
        }
        
        let filter = TransferHistoryListFetcher.Filter(userId: originFilter.userId, direction: direction, transferType: transferType, symbol: originFilter.symbol, rewards: rewards)
        
        dismiss(animated: true) {
            self.completion?(filter)
        }
    }
    
    @objc func reset() {
        setUp(with: TransferHistoryListFetcher.Filter(userId: originFilter.userId, direction: "all", transferType: nil, symbol: originFilter.symbol, rewards: nil))
    }
    
    private func setUp(with filter: TransferHistoryListFetcher.Filter) {
        // first filter
        switch filter.direction {
        case "all":
            segmentedControl.selectedIndex = 0
        case "receive":
            segmentedControl.selectedIndex = 1
        case "send":
            segmentedControl.selectedIndex = 2
        default:
            segmentedControl.selectedIndex = 0
        }
        
        // filter by transferType
        switch filter.transferType {
        case "all":
            typeSegmentedControl.selectedIndex.accept(-1)
        case "transfer":
            typeSegmentedControl.selectedIndex.accept(0)
        case "convert":
            typeSegmentedControl.selectedIndex.accept(1)
        default:
            typeSegmentedControl.selectedIndex.accept(-1)
        }
        
        // filter by rewards
        switch filter.rewards {
        case "all":
            rewardsSegmentedControl.selectedIndex.accept(0)
        case "none":
            rewardsSegmentedControl.selectedIndex.accept(1)
//        case "like":
//            rewardsSegmentedControl.selectedIndex.accept(1)
//        case "comment":
//            rewardsSegmentedControl.selectedIndex.accept(2)
        default:
            rewardsSegmentedControl.selectedIndex.accept(0)
//            rewardsSegmentedControl.selectedIndex.accept(-1)
        }
    }
}
