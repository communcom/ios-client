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
    lazy var segmentedControl: TransferHistorySegmentedControl = {
        let smControl = TransferHistorySegmentedControl(height: 60 * Config.heightRatio)
        smControl.labels = ["all".localized().uppercaseFirst, "income".localized().uppercaseFirst, "outcome".localized().uppercaseFirst]
        return smControl
    }()
    
    lazy var typeSegmentedControl: CMHorizontalTabBar = {
        let sc = CMHorizontalTabBar(height: 35)
        sc.labels = ["transfer".localized().uppercaseFirst, "convert".localized().uppercaseFirst]
        sc.canChooseNone = true
        return sc
    }()
    
    lazy var rewardsSegmentedControl: CMHorizontalTabBar = {
        let sc = CMHorizontalTabBar(height: 35)
        sc.labels = ["all".localized().uppercaseFirst, "noone".localized().uppercaseFirst]
        return sc
    }()
    
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
        
        // add stackViews
        let stackView = UIStackView(axis: .vertical, alignment: .leading, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoPinEdge(.top, to: .bottom, of: closeButton, withOffset: 24 * Config.heightRatio)
        stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.widthRatio)
        stackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.widthRatio)
        stackView.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 16)
        
        // add subviews
        let typeLabel = UILabel.with(text: "type".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .appGrayColor)
        let rewardsLabel = UILabel.with(text: "rewards".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .appGrayColor)
        let saveButton = CommunButton.default(height: 50 * Config.heightRatio, label: "save".localized().uppercaseFirst, isHuggingContent: false)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        let clearAllButton = UIButton(height: 50 * Config.heightRatio, label: "clear all".localized().uppercaseFirst, labelFont: UIFont.systemFont(ofSize: 15, weight: .semibold), backgroundColor: .appLightGrayColor, textColor: .appMainColor, cornerRadius: 50 * Config.heightRatio / 2)
        clearAllButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        
        stackView.addArrangedSubviews([
            segmentedControl,
            typeLabel,
            typeSegmentedControl,
            rewardsLabel,
            rewardsSegmentedControl,
            saveButton,
            clearAllButton
        ])
        
        segmentedControl.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        typeSegmentedControl.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        rewardsSegmentedControl.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        clearAllButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.setCustomSpacing(30 * Config.heightRatio, after: segmentedControl)
        stackView.setCustomSpacing(20 * Config.heightRatio, after: typeLabel)
        stackView.setCustomSpacing(30 * Config.heightRatio, after: typeSegmentedControl)
        stackView.setCustomSpacing(20 * Config.heightRatio, after: rewardsLabel)
        stackView.setCustomSpacing(40 * Config.heightRatio, after: rewardsSegmentedControl)
        stackView.setCustomSpacing(10, after: saveButton)
        
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
        switch typeSegmentedControl.selectedIndex {
        case 0:
            transferType = "transfer"
        case 1:
            transferType = "convert"
        default:
            break
        }
        
        var rewards: String?
        switch rewardsSegmentedControl.selectedIndex {
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
            typeSegmentedControl.selectedIndex = nil
        case "transfer":
            typeSegmentedControl.selectedIndex = 0
        case "convert":
            typeSegmentedControl.selectedIndex = 1
        default:
            typeSegmentedControl.selectedIndex = nil
        }
        
        // filter by rewards
        switch filter.rewards {
        case "all":
            rewardsSegmentedControl.selectedIndex = 0
        case "none":
            rewardsSegmentedControl.selectedIndex = 1
//        case "like":
//            rewardsSegmentedControl.selectedIndex.accept(1)
//        case "comment":
//            rewardsSegmentedControl.selectedIndex.accept(2)
        default:
            rewardsSegmentedControl.selectedIndex = 0
//            rewardsSegmentedControl.selectedIndex.accept(-1)
        }
    }
}
