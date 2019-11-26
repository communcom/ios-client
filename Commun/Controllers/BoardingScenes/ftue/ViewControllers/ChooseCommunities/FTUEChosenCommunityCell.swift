//
//  FTUEChosenCommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class FTUEChosenCommunityCell: MyCollectionViewCell {
    lazy var avatarImageView = LeaderAvatarImageView(size: 50)
    lazy var deleteButton: UIButton = {
        let button = UIButton.circle(size: 20, backgroundColor: .appMainColor, tintColor: .white, imageName: "close-x", imageEdgeInsets: UIEdgeInsets(inset: 6))
        button.borderWidth = 2
        button.borderColor = .white
        return button
    }()
    
    var community: ResponseAPIContentGetCommunity?
    weak var delegate: CommunityCollectionCellDelegate?
    
    override func setUpViews() {
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges()
        
        contentView.addSubview(deleteButton)
        deleteButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        deleteButton.autoPinEdge(.top, to: .top, of: avatarImageView)
        
        deleteButton.addTarget(self, action: #selector(buttonDeleteDidTouch), for: .touchUpInside)
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        avatarImageView.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
        avatarImageView.percent = 1
    }
    
    @objc func buttonDeleteDidTouch() {
        guard let community = community else {return}
        delegate?.forceFollow(false, community: community)
    }
}
