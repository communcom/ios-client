//
//  TopicCell.swift
//  Commun
//
//  Created by Chung Tran on 9/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class TopicCell: MyTableViewCell {
    lazy var stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var label = UILabel.with(textSize: 15, weight: .medium)
    lazy var optionButton = UIButton.option()
    
    override func setUpViews() {
        super.setUpViews()
        selectionStyle = .none
        backgroundColor = .clear
        // background color
        contentView.backgroundColor = .clear
        let containerView = UIView(height: 44, backgroundColor: .appWhiteColor, cornerRadius: 10)
        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
        
        containerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 10))
        
        stackView.addArrangedSubview(label)
//        stackView.addArrangedSubview(optionButton)
        
        optionButton.isUserInteractionEnabled = false
    }
}
