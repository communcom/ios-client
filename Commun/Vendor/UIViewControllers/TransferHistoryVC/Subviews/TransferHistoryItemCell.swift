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
    lazy var stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var containerView = UIView(backgroundColor: .appWhiteColor)
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(width: 22, height: 22, cornerRadius: 11)
        imageView.borderColor = .appWhiteColor
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
        
        containerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: 16, vertical: 10))
        
        let avatarContainerView = UIView(forAutoLayout: ())
        avatarContainerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 2))
        
        avatarContainerView.addSubview(iconImageView)
        iconImageView.autoPinEdge(.bottom, to: .bottom, of: avatarImageView, withOffset: 2)
        iconImageView.autoPinEdge(.trailing, to: .trailing, of: avatarImageView, withOffset: 2)
        
        stackView.addArrangedSubviews([avatarContainerView, contentLabel, amountStatusLabel])
    }
    
    func setUp(with item: ResponseAPIWalletGetTransferHistoryItem) {
        self.item = item

        var username: String
        var memo: NSAttributedString
        
        var pointName = item.point.name ?? item.symbol
        if pointName == "CMN" {pointName = "Commun"}
        
        switch item.meta.actionType {
        case "transfer":
            var avatarUrl: String?
            if item.meta.direction == "send" {
                avatarUrl = item.receiver.avatarUrl
                username = item.receiver.username ?? item.receiver.userId
                memo = NSMutableAttributedString()
                    .semibold("-\(item.quantityValue.currencyValueFormatted) \(pointName)", font: .systemFont(ofSize: 15, weight: .semibold))
            } else {
                avatarUrl = item.sender.avatarUrl
                username = item.sender.username ?? item.sender.userId
                memo = NSMutableAttributedString()
                    .semibold("+\(item.quantityValue.currencyValueFormatted) \(pointName)", font: .systemFont(ofSize: 15, weight: .semibold), color: .appGreenColor)
            }
            
            avatarImageView.setAvatar(urlString: avatarUrl)
            
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: "tux")
            
        case "convert":
            username = "refill".localized().uppercaseFirst
            if item.meta.transferType == "token" {
                memo = NSMutableAttributedString()
                    .semibold("+\((item.meta.exchangeAmount ?? 0).currencyValueFormatted) \(pointName)", font: .systemFont(ofSize: 15, weight: .semibold), color: .appGreenColor)
                iconImageView.isHidden = false
                avatarImageView.setAvatar(urlString: item.point.logo)
                iconImageView.image = UIImage(named: "tux")
            } else {
                memo = NSMutableAttributedString()
                    .semibold("+\((item.meta.exchangeAmount ?? 0).currencyValueFormatted) Commun", font: .systemFont(ofSize: 15, weight: .semibold), color: .appGreenColor)
                iconImageView.isHidden = false
                iconImageView.sd_setImage(with: URL(string: item.point.logo ?? ""), placeholderImage: UIImage(color: .appMainColor))
                avatarImageView.image = UIImage(named: "tux")
            }
        case "reward":
            username = item.point.name ?? ""
            memo = NSMutableAttributedString()
                .semibold("+\(item.quantityValue.currencyValueFormatted) \(pointName)", font: .systemFont(ofSize: 15, weight: .semibold), color: .appGreenColor)
            
            avatarImageView.setAvatar(urlString: item.point.logo)
            iconImageView.isHidden = true
        case "hold":
            username = item.meta.holdType?.localized().uppercaseFirst ?? ""
            memo = NSMutableAttributedString()
                .semibold("\(item.quantityValue.currencyValueFormatted) \(pointName)")
            
            avatarImageView.image = UIImage(named: "wallet-like")
            iconImageView.isHidden = true
        case "unhold":
            username = item.point.name ?? ""
            memo = NSMutableAttributedString()
                .semibold("+\(item.quantityValue.currencyValueFormatted) \(pointName)", font: .systemFont(ofSize: 15, weight: .semibold), color: .appGreenColor)
            
            avatarImageView.setAvatar(urlString: item.point.logo)
            iconImageView.isHidden = true
        case "referralRegisterBonus":
            username = item.sender.username ?? item.sender.userId
            memo = NSMutableAttributedString()
                .semibold("+\(item.quantityValue.currencyValueFormatted) \(pointName)", color: .appGreenColor)
            avatarImageView.image = UIImage(named: "notifications-page-referral")
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: "tux")
        case "referralPurchaseBonus":
            username = item.sender.username ?? item.sender.userId
            memo = NSMutableAttributedString()
                .semibold("+\(item.quantityValue.currencyValueFormatted) \(pointName)", color: .appGreenColor)
            avatarImageView.image = UIImage(named: "notifications-page-referral")
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: "tux")
        case "donation":
            let isReceiver = Config.currentUser?.id == item.receiver.userId
            var profile: ResponseAPIWalletGetTransferHistoryProfile?
            if isReceiver {
                profile = item.sender
            } else {
                profile = item.receiver
            }
            
            username = profile?.username ?? profile?.userId ?? "A user"
            
            if isReceiver {
                memo = NSMutableAttributedString()
                    .semibold("+\(item.quantityValue.currencyValueFormatted) \(pointName)", color: .appGreenColor)
            } else {
                memo = NSMutableAttributedString()
                    .semibold("-\(item.quantityValue.currencyValueFormatted) \(pointName)", font: .systemFont(ofSize: 15, weight: .semibold))
            }
            avatarImageView.setAvatar(urlString: profile?.avatarUrl)
            iconImageView.isHidden = false
            if let logo = item.point.logo, let url = URL(string: logo) {
                iconImageView.sd_setImage(with: url, completed: nil)
            } else {
                iconImageView.image = UIImage(named: "tux")
            }
        default:
            username = ""
            memo = NSMutableAttributedString()
            avatarImageView.image = UIImage(named: "empty-avatar")
            iconImageView.isHidden = true
        }
        
        let content = NSMutableAttributedString()
            .semibold(username)
        
        content
            .normal("\n")
            
        if item.meta.actionType == "referralRegisterBonus" {
            content
                .semibold("you received a referral bonus for the registration of".localized().uppercaseFirst, font: .systemFont(ofSize: 12, weight: .semibold), color: .appGrayColor)
                .semibold(" ")
                .semibold(item.referral?.username ?? item.referral?.userId ?? "", font: .systemFont(ofSize: 12, weight: .semibold), color: .appMainColor)
        } else if item.meta.actionType == "referralPurchaseBonus" {
            content
                .semibold("you received a referral bounty - 5% of".localized().uppercaseFirst, font: .systemFont(ofSize: 12, weight: .semibold), color: .appGrayColor)
                .semibold(" ")
                .semibold(item.referral?.username ?? item.referral?.userId ?? "", font: .systemFont(ofSize: 12, weight: .semibold), color: .appMainColor)
                .semibold("'s", font: .systemFont(ofSize: 12, weight: .semibold), color: .appGrayColor)
                .semibold(" ")
                .semibold("purchase".localized(), font: .systemFont(ofSize: 12, weight: .semibold), color: .appGrayColor)
        } else {
            content
                .semibold(item.meta.actionType?.localized().uppercaseFirst ?? "", font: .systemFont(ofSize: 12, weight: .semibold), color: .appGrayColor)
        }
    
        contentLabel.attributedText = content
        
        let dateString = Date.from(string: item.timestamp).string(withFormat: "HH:mm")
        
        amountStatusLabel.attributedText =
            NSMutableAttributedString(attributedString: memo)
                .normal("\n")
                .semibold(dateString, font: .systemFont(ofSize: 12, weight: .semibold), color: .appGrayColor)
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
