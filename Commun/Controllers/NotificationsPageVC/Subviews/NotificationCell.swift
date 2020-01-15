//
//  NotificationCell.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

protocol NotificationCellDelegate: class {}

class NotificationCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: NotificationCellDelegate?
    var item: ResponseAPIGetNotificationItem?
    
    // MARK: - Subviews
    lazy var isNewMark = UIView(width: 6, height: 6, backgroundColor: .appMainColor, cornerRadius: 3)
    lazy var avatarImageView = MyAvatarImageView(size: 44)
    
    
    // MARk: - Methods
    func setUp(with item: ResponseAPIGetNotificationItem) {
        self.item = item
    }
}
