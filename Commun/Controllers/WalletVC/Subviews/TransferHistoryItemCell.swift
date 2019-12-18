//
//  TransferHistoryItemCell.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

protocol TransferHistoryItemCellDelegate: class {}

class TransferHistoryItemCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: TransferHistoryItemCellDelegate?
    var item: ResponseAPIWalletGetTransferHistoryItem?
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(width: 22, height: 22, cornerRadius: 11)
        imageView.borderColor = .white
        imageView.borderWidth = 2
        return imageView
    }()
    lazy var contentLabel = UILabel.with(text: "Ivan Bilin\nTransaction", textSize: 15, weight: .semibold, numberOfLines: 0)
    lazy var amountStatusLabel = UILabel.with(text: "-500 Commun\nOn hold", textSize: 15, weight: .semibold, numberOfLines: 2, textAlignment: .right)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .white
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 0), excludingEdge: .trailing)
        
        contentView.addSubview(iconImageView)
        iconImageView.autoPinEdge(.bottom, to: .bottom, of: avatarImageView)
        iconImageView.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        
        contentView.addSubview(contentLabel)
        contentLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        contentView.addSubview(amountStatusLabel)
        amountStatusLabel.autoPinEdge(.leading, to: .trailing, of: contentLabel, withOffset: 10)
        amountStatusLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        amountStatusLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        amountStatusLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    func setUp(with item: ResponseAPIWalletGetTransferHistoryItem) {
        self.item = item
        
    }
}
