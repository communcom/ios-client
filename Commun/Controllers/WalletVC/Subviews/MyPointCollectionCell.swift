//
//  MyPointCollectionCell.swift
//  Commun
//
//  Created by Chung Tran on 12/20/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class MyPointCollectionCell: MyCollectionViewCell {
    // MARK: - Constants
    static let height: CGFloat = 190
    
    // MARK: - Properties
    var balance: ResponseAPIWalletGetBalance?
    
    // MARK: - Subviews
    lazy var logoImageView = MyAvatarImageView(size: 50)
    lazy var nameLabel = UILabel.with(text: "Commun", textSize: 17, weight: .semibold, numberOfLines: 2)
    lazy var pointLabel = UILabel.with(textSize: 20, numberOfLines: 2)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .white
        contentView.cornerRadius = 10
        
        contentView.addSubview(logoImageView)
        logoImageView.autoPinTopAndLeadingToSuperView(inset: 16)
        
        contentView.addSubview(nameLabel)
        nameLabel.autoPinEdge(.top, to: .bottom, of: logoImageView, withOffset: 10)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        contentView.addSubview(pointLabel)
        pointLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
    }
    
    func setUp(with balance: ResponseAPIWalletGetBalance) {
        self.balance = balance
        
        if balance.symbol == "CMN" {
            logoImageView.image = UIImage(named: "tux")
            nameLabel.attributedText = NSAttributedString(string: "Commun", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .semibold)])
            pointLabel.attributedText = NSMutableAttributedString()
                .text(balance.balance, size: 20, weight: .semibold)
                .text(" " + "token".localized().uppercaseFirst, size: 12, weight: .semibold, color: .a5a7bd)
                .withParagraphSpacing(4)
        } else {
            logoImageView.setAvatar(urlString: balance.logo, namePlaceHolder: balance.name ?? "B")
            nameLabel.attributedText = NSMutableAttributedString()
                .text(balance.name ?? "B", size: 17, weight: .semibold)
                .text("\n\(balance.frozen ?? "0") " + "on hold".localized(), size: 12, weight: .semibold, color: .a5a7bd)
                .withParagraphSpacing(4)
            pointLabel.attributedText = NSMutableAttributedString()
                .text(balance.balance, size: 20, weight: .semibold)
                .text(" " + "points".localized().uppercaseFirst, size: 12, weight: .semibold, color: .a5a7bd)
                .text("\n= \(balance.priceValue) Commun", size: 12, weight: .semibold, color: .a5a7bd)
                .withParagraphSpacing(4)
        }
    }
}
