//
//  CommentCell.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommentCell: MyTableViewCell {
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    lazy var contentContainerView = UIView(backgroundColor: .f3f5fa)
    lazy var contentLabel = UILabel.with(text: "Andrey Ivanov Welcome! 😄 Wow would love to wake", textSize: 15, numberOfLines: 0)
    lazy var embedView = UIView(height: 101)
    
}
