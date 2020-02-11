//
//  SubscriptionsItemCell.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

/// Reusable itemcell for subscribers/subscriptions
class SubsItemCell: MyTableViewCell {
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var nameLabel = UILabel.with(textSize: 15, weight: .semibold, numberOfLines: 0)
    lazy var statsLabel = UILabel.descriptionLabel(numberOfLines: 0)
    lazy var actionButton = CommunButton.default()
    lazy var separator = UIView(height: 2, backgroundColor: .f3f5fa)
    
    override var roundedCorner: UIRectCorner {
        didSet {
            if roundedCorner.contains(.bottomLeft) {
                separator.isHidden = true
            } else {
                separator.isHidden = false
            }
            layoutSubviews()
        }
    }
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .white
        selectionStyle = .none
        
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
        // name, stats label
        let vStack = UIStackView(axis: .vertical, spacing: 3, alignment: .leading, distribution: .fill)
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        vStack.addArrangedSubview(nameLabel)
        vStack.addArrangedSubview(statsLabel)
        
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(vStack)
        stackView.addArrangedSubview(actionButton)
        
        // separator
        contentView.addSubview(separator)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        actionButton.addTarget(self, action: #selector(actionButtonDidTouch), for: .touchUpInside)
    }
    
    @objc func actionButtonDidTouch() {
        
    }
}
