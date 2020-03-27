//
//  CurrencyCell.swift
//  Commun
//
//  Created by Chung Tran on 1/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol CurrencyCellDelegate: class {}

class CurrencyCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: CurrencyCellDelegate?
    var item: ResponseAPIGetCurrency?
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var contentLabel = UILabel.with(textSize: 15, weight: .medium, numberOfLines: 2)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        
        contentView.addSubview(contentLabel)
        contentLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        contentLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
    
    func setUp(with item: ResponseAPIGetCurrency) {
        self.item = item
        avatarImageView.setAvatar(urlString: item.image, namePlaceHolder: item.name)
        
        contentLabel.attributedText = NSMutableAttributedString()
            .text(item.name.uppercased(), size: 15, weight: .medium)
            .normal("\n")
            .text(item.fullName ?? "", size: 12, weight: .medium, color: .a5a7bd)
    }
}
