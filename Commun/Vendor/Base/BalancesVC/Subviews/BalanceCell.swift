//
//  BalanceCell.swift
//  Commun
//
//  Created by Chung Tran on 12/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

protocol BalanceCellDelegate: class {}

class BalanceCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: BalanceCellDelegate?
    var item: ResponseAPIWalletGetBalance?
    
    // MARK: - Subviews
    lazy var containerView = UIView(backgroundColor: .white, cornerRadius: 10)
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var firstLabel = UILabel.with(text: "Overwatch\n4000 on hold", textSize: 15, weight: .semibold, numberOfLines: 0)
    lazy var secondLabel = UILabel.with(text: "21 000 points\n= 150 Commun", textSize: 15, weight: .semibold, numberOfLines: 0, textAlignment: .right)
    
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
        
        containerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        
        containerView.addSubview(firstLabel)
        firstLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        firstLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        containerView.addSubview(secondLabel)
        secondLabel.autoPinEdge(.leading, to: .trailing, of: firstLabel, withOffset: 10)
        secondLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        secondLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        secondLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func setUp(with item: ResponseAPIWalletGetBalance) {
        self.item = item
        
        if item.symbol == "CMN" {
            avatarImageView.image = UIImage(named: "tux")
        } else {
            avatarImageView.setAvatar(urlString: item.logo, namePlaceHolder: item.name ?? "B")
        }
        
        var firstText = NSMutableAttributedString()
            .text(item.name ?? "Commun", size: 15, weight: .semibold)
            .text("\n")
        if item.frozen != nil {
            firstText = firstText.text("\(item.frozenValue.currencyValueFormatted) " + "on hold".localized().uppercaseFirst, size: 12, weight: .semibold, color: .a5a7bd)
                .withParagraphSpacing(4)
            firstLabel.numberOfLines = 2
        } else {
            firstLabel.numberOfLines = 1
        }
        firstLabel.attributedText = firstText
        
        var secondText = NSMutableAttributedString()
            .text(item.balanceValue.currencyValueFormatted, size: 15, weight: .semibold)
            .text(" " + "points".localized().uppercaseFirst, size: 15, weight: .semibold)
            
        if item.symbol != "CMN" {
            secondText = secondText
                .text("\n= \(item.communValue.currencyValueFormatted) Commun", size: 12, weight: .semibold, color: .a5a7bd)
            secondLabel.numberOfLines = 2
        } else {
            secondLabel.numberOfLines = 1
        }
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        paragraphStyle.paragraphSpacing = 4
        secondText.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: secondText.length))
        
        secondLabel.attributedText = secondText
    }
}
