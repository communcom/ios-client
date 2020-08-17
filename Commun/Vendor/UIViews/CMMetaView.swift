//
//  CMMetaView.swift
//  Commun
//
//  Created by Chung Tran on 8/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMMetaView: MyView {
    lazy var stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var avatarImageView = MyAvatarImageView(size: 40)
    lazy var titleLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var subtitleLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .appGrayColor)
    lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(axis: .vertical, spacing: 3, alignment: .leading)
        stackView.addArrangedSubviews([titleLabel, subtitleLabel])
        return stackView
    }()
    
    override func commonInit() {
        super.commonInit()
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        stackView.addArrangedSubviews([avatarImageView, labelStackView])
        
    }
}
