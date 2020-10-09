//
//  CommunityBannedUserCell.swift
//  Commun
//
//  Created by Chung Tran on 10/9/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import Action

class CommunityBannedUserCell: SubscribersCell {
    class UnbanButton: UIButton {
        override var isEnabled: Bool {
            didSet {
                alpha = isEnabled ? 1: 0.5
            }
        }
    }
    
    lazy var unBanButton = UnbanButton(label: "unban".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .semibold), textColor: .appMainColor)
        .huggingContent(axis: .horizontal)
    override func setUpViews() {
        super.setUpViews()
        showFollowersFollowings = false
        stackView.addArrangedSubview(unBanButton)
    }
    
    override func setUp(with profile: ResponseAPIContentGetProfile) {
        super.setUp(with: profile)
        actionButton.isHidden = true
    }
    
    func setUpUnBanAction(_ action: CocoaAction) {
        unBanButton.rx.action = action
    }
}
