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
    lazy var containerView = UIView(backgroundColor: .white)
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
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        containerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 0), excludingEdge: .trailing)
        
        containerView.addSubview(iconImageView)
        iconImageView.autoPinEdge(.bottom, to: .bottom, of: avatarImageView, withOffset: 2)
        iconImageView.autoPinEdge(.trailing, to: .trailing, of: avatarImageView, withOffset: 2)
        
        containerView.addSubview(contentLabel)
        contentLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        containerView.addSubview(amountStatusLabel)
        amountStatusLabel.autoPinEdge(.leading, to: .trailing, of: contentLabel, withOffset: 10)
        amountStatusLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        amountStatusLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        amountStatusLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    func setUp(with item: ResponseAPIWalletGetTransferHistoryItem) {
        self.item = item

        var username: String
        var memo: NSAttributedString
        
        switch item.meta.actionType {
        case "transfer":
            var avatarUrl: String?
            if item.meta.direction == "send" {
                avatarUrl = item.receiver.avatarUrl
                username = item.receiver.username ?? item.receiver.userId
                memo = NSMutableAttributedString()
                    .semibold("-\(item.quantityValue.currencyValueFormatted) \(item.point.name ?? item.symbol)", font: .systemFont(ofSize: 15, weight: .semibold))
            } else {
                avatarUrl = item.sender.avatarUrl
                username = item.sender.username ?? item.sender.userId
                memo = NSMutableAttributedString()
                    .semibold("+\(item.quantityValue.currencyValueFormatted) \(item.point.name ?? item.symbol)", font: .systemFont(ofSize: 15, weight: .semibold), color: .plus)
            }
            
            avatarImageView.setAvatar(urlString: avatarUrl, namePlaceHolder: username)
            
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: "tux")
            
        case "convert":
            username = "refill".localized().uppercaseFirst
            if item.meta.transferType == "token" {
                memo = NSMutableAttributedString()
                    .semibold("+\((item.meta.exchangeAmount ?? 0).currencyValueFormatted) \(item.point.name!)", font: .systemFont(ofSize: 15, weight: .semibold), color: .plus)
                iconImageView.isHidden = false
                avatarImageView.setAvatar(urlString: item.point.logo, namePlaceHolder: item.point.name ?? "C")
                iconImageView.image = UIImage(named: "tux")
            } else {
                memo = NSMutableAttributedString()
                    .semibold("+\((item.meta.exchangeAmount ?? 0).currencyValueFormatted) Commun", font: .systemFont(ofSize: 15, weight: .semibold), color: .plus)
                iconImageView.isHidden = false
                iconImageView.sd_setImage(with: URL(string: item.point.logo ?? ""), placeholderImage: UIImage(color: .appMainColor))
                avatarImageView.image = UIImage(named: "tux")
            }
        case "reward":
            username = item.point.name ?? ""
            memo = NSMutableAttributedString()
                .semibold("+\(item.quantityValue.currencyValueFormatted) \(item.point.name!)", font: .systemFont(ofSize: 15, weight: .semibold), color: .plus)
            
            avatarImageView.setAvatar(urlString: item.point.logo, namePlaceHolder: username)
            iconImageView.isHidden = true
        case "hold":
            username = item.meta.holdType?.localized().uppercaseFirst ?? ""
            memo = NSMutableAttributedString()
                .semibold("+\(item.quantityValue.currencyValueFormatted) \(item.point.name!)", font: .systemFont(ofSize: 15, weight: .semibold), color: .plus)
            
            avatarImageView.image = UIImage(named: "wallet-like")
            iconImageView.isHidden = true
        case "unhold":
            username = item.point.name ?? ""
            memo = NSMutableAttributedString()
                .semibold("+\(item.quantityValue.currencyValueFormatted) \(item.point.name!)", font: .systemFont(ofSize: 15, weight: .semibold), color: .plus)
            
            avatarImageView.setAvatar(urlString: item.point.logo, namePlaceHolder: username)
            iconImageView.isHidden = true
        default:
            username = ""
            memo = NSMutableAttributedString()
            iconImageView.isHidden = true
        }
        
        let content = NSMutableAttributedString()
            .semibold(username)
        
        content
            .normal("\n")
            .semibold(item.meta.actionType?.localized().uppercaseFirst ?? "", font: .systemFont(ofSize: 12, weight: .semibold), color: .a5a7bd)
    
        
        contentLabel.attributedText = content
        
        let dateString = Date.from(string: item.timestamp).string(withFormat: "HH:mm")
        
        amountStatusLabel.attributedText =
            NSMutableAttributedString(attributedString: memo)
                .normal("\n")
                .semibold(dateString, font: .systemFont(ofSize: 12, weight: .semibold), color: .a5a7bd)
    }
    
    override func roundCorners() {
        if roundedCorner.isEmpty {return}
        if containerView.height == 0 {
            DispatchQueue.main.async {
                self.roundCorners()
            }
        } else {
            containerView.roundCorners(roundedCorner, radius: 16)
        }
    }
}
