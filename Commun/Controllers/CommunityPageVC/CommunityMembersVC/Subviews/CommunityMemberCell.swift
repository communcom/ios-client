//
//  CommunityMemberCell.swift
//  Commun
//
//  Created by Chung Tran on 10/6/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import Action

class CommunityMemberCell: SubscribersCell {
    lazy var optionButton = UIButton.option(tintColor: .appGrayColor)
    
    override func setUpViews() {
        super.setUpViews()
        stackView.addArrangedSubview(optionButton)
        optionButton.isHidden = true
    }
}
