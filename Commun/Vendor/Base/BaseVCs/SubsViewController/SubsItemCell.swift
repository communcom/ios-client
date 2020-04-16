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
    lazy var stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var contentLabel = UILabel.with(numberOfLines: 0)
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
        
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
        // name, stats label
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(actionButton)
        
        // separator
        contentView.addSubview(separator)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        actionButton.addTarget(self, action: #selector(actionButtonDidTouch), for: .touchUpInside)
    }
    
    func hideActionButton() {
        stackView.removeArrangedSubview(actionButton)
        actionButton.removeFromSuperview()
    }
    
    @objc func actionButtonDidTouch() {
        
    }
}
