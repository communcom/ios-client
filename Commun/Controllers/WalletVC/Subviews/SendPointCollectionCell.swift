//
//  SendPointCollectionCell.swift
//  Commun
//
//  Created by Chung Tran on 12/20/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class SendPointCollectionCell: MyCollectionViewCell {
    // MARK: - Constants
    static let height: CGFloat = 124
    
    // MARK: - Properties
    var user: ResponseAPIContentGetProfile?
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var nameLabel = UILabel.with(textSize: 12, weight: .semibold, numberOfLines: 2, textAlignment: .center)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .white
        contentView.cornerRadius = 10
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        contentView.addSubview(nameLabel)
        nameLabel.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 10)
        nameLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
    }
    
    func setUp(with user: ResponseAPIContentGetProfile?) {
        self.user = user
        if let user = user {
            avatarImageView.setAvatar(urlString: user.avatarUrl)
            nameLabel.text = user.username
        } else {
            // add friend
            avatarImageView.image = UIImage(named: "add-circle")
            nameLabel.text = String(format: "%@ %@", "add".localized().uppercaseFirst, "friend".localized())
        }
    }
}
