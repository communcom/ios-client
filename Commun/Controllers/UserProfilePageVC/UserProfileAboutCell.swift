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
    
    func setUp(with post: ResponseAPIContentGetProfile) {
        
    }
}
