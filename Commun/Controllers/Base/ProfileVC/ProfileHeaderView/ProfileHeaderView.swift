//
//  ProfileHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class ProfileHeaderView: MyTableHeaderView {
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    
    lazy var nameLabel: UILabel = {
        let label = UILabel.with(text: "Profile", textSize: 20, weight: .bold)
        return label
    }()
    
    lazy var joinedDateLabel: UILabel = {
        let label = UILabel.descriptionLabel("Joined", size: 12)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel.with(text: "Binance Exchange provides cryptocurrency trading for fintech and blockchain enthusiasts", textSize: 14, numberOfLines: 0)
        return label
    }()
    
    lazy var usersStackView: UsersStackView = {
        let stackView = UsersStackView(height: 34)
        return stackView
    }()
    
    lazy var segmentedControl: CMSegmentedControl = {
        let segmentedControl = CMSegmentedControl(height: 46, backgroundColor: .clear)
        return segmentedControl
    }()
}
