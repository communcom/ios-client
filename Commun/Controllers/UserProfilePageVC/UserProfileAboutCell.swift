//
//  UserProfileAboutCell.swift
//  Commun
//
//  Created by Chung Tran on 9/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol UserProfileAboutCellProtocol: class {}
class UserProfileAboutCell: MyTableViewCell, ListItemCellType {
    weak var delegate: UserProfileAboutCellProtocol?
    lazy var userProfileDetailVC = MyProfileDetailVC()
    lazy var userProfileInfoView = UserProfileInfoView(forAutoLayout: ())
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .appLightGrayColor
        addSubview(userProfileInfoView)
        userProfileInfoView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
    }
    
    func setUp(with profile: ResponseAPIContentGetProfile) {
        userProfileInfoView.setUp(with: profile)
    }
}
