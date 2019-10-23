//
//  CommunityHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityHeaderView: UIView {
    // MARK: - Properties
    weak var tableView: UITableView?
    
    // MARK: - Subviews
    lazy var backButton: UIButton {
        let button = UIButton(width: 24, height: 40, contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 12))
        button.setImage(UIImage(named: ""), for: .normal)
        return button
    }
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(height: 180)
        imageView.image = UIImage(named: "ProfilePageCover")
        return imageView
    }()
    
    
}
