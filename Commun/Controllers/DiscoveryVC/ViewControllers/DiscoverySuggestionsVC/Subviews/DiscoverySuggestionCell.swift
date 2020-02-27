//
//  DiscoverySuggestionCell.swift
//  Commun
//
//  Created by Chung Tran on 2/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol DiscoverySuggestionCellDelegate: class {}

class DiscoverySuggestionCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: DiscoverySuggestionCellDelegate?
    var item: ResponseAPIContentSearchItem?
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 30)
    lazy var nameLabel = UILabel.with(textSize: 14, weight: .medium, numberOfLines: 0)
    
    // MARK: - Method
    override func setUpViews() {
        super.setUpViews()
        let hStack = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        contentView.addSubview(hStack)
        hStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        
        hStack.addArrangedSubviews([avatarImageView, nameLabel])
        
        selectionStyle = .none
    }
    
    func setUp(with item: ResponseAPIContentSearchItem) {
        self.item = item
        
        if let community = item.communityValue {
            avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
            nameLabel.text = community.name
        } else if let user = item.profileValue {
            avatarImageView.setAvatar(urlString: user.avatarUrl, namePlaceHolder: user.username)
            nameLabel.text = user.username
        }
    }
}
