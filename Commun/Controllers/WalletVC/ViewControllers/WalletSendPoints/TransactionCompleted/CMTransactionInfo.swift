//
//  CMTransactionBill.swift
//  Commun
//
//  Created by Chung Tran on 4/2/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMTransactionInfo: MyView {
    // MARK: - Properties
    let transaction: Transaction
    let parentColor: UIColor
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, distribution: .fill)
    
    lazy var dashLines = [0, 1].compactMap {_ in UIView(height: 2)}
    
    // MARK: - Initializers
    init(transaction: Transaction, parentColor: UIColor = .clear) {
        self.transaction = transaction
        self.parentColor = parentColor
        super.init(frame: .zero)
        
        defer {
            configureForAutoLayout()
            backgroundColor = .white
            cornerRadius = 20
            clipsToBounds = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        
        // first part
        let readyCheckMark = UIImageView.circle(size: 60, backgroundColor: #colorLiteral(red: 0.3125971854, green: 0.8584119678, blue: 0.6879913807, alpha: 1), imageName: "icon-checkmark-white")
        readyCheckMark.addShadow(ofColor: #colorLiteral(red: 0.732, green: 0.954, blue: 0.886, alpha: 1), radius: 24.0, offset: CGSize(width: 0.0, height: 8.0), opacity: 1.0)
        
        let transactionCompletedLabel = UILabel.with(text: "transaction completed".localized().uppercaseFirst, textSize: 17, weight: .bold, textAlignment: .center)
        let transactionTimestampLabel = UILabel.with(text: transaction.operationDate.convert(toStringFormat: .transactionCompletedType), textSize: 12, weight: .semibold, textColor: .appGrayColor, textAlignment: .center)
        
        let separator0 = separatorWithIndex(0)
        
        // second part
        let amount = transaction.amount
        let textColor: UIColor = amount > 0 ? .appGreenColor : .black
        let amountLabel = UILabel.with(textSize: 20)
        amountLabel.attributedString = NSMutableAttributedString()
            .text((amount > 0 ? "+" : "-") + String(Double(abs(amount)).currencyValueFormatted + " "), size: 20, weight: .semibold, color: textColor)
            .text(transaction.symbol.buy.fullName, size: 20, color: textColor)
        
        let burnedPercentLabel = UILabel.with(text: String(format: "%.1f%% %@ 🔥", 0.1, "was burned".localized()), textSize: 12, weight: .semibold, textColor: .appGrayColor, textAlignment: .center)
        
        let buyerAvatarImageView = MyAvatarImageView(size: 40)
        
        let buyerNameLabel = UILabel.with(textSize: 17, weight: .bold, textAlignment: .center)
        
        let buyerBalanceOrFriendIDLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .appGrayColor, textAlignment: .center)
        
        let separator1 = separatorWithIndex(1)
        
        // third part
        let debitedFromLabel = UILabel.with(text: "debited from".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: .appGrayColor)
        
        let blueBottomView: UIView = {
            let view = UIView(backgroundColor: .appMainColor, cornerRadius: 16)
            
            let imageView: UIView
            if let sellBalance = transaction.sellBalance, let avatarURL = sellBalance.avatarURL {
                let avatarImageView = UIImageView.circle(size: 30.0)
                avatarImageView.setAvatar(urlString: avatarURL, namePlaceHolder: "icon-select-user-grey-cyrcle-default")
                imageView = avatarImageView
            } else {
                let communLogo = UIView.transparentCommunLogo(size: 30.0, backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2))
                imageView = communLogo
            }
            
            view.addSubview(imageView)
            imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 26, right: 0), excludingEdge: .trailing)
            
            let sellerNameLabel = UILabel.with(text: transaction.sellBalance?.name, textSize: 15, weight: .semibold, textColor: .white)
            view.addSubview(sellerNameLabel)
            sellerNameLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
            sellerNameLabel.autoAlignAxis(.horizontal, toSameAxisOf: imageView)
            sellerNameLabel.setContentHuggingPriority(249.0, for: .horizontal)
            sellerNameLabel.text = transaction.sellBalance?.name
            
            let sellerAmountLabel = UILabel.with(textSize: 15, weight: .bold, textColor: .white, textAlignment: .right)
            view.addSubview(sellerAmountLabel)
            sellerAmountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            sellerAmountLabel.autoAlignAxis(.horizontal, toSameAxisOf: imageView)
            sellerAmountLabel.autoPinEdge(.leading, to: .trailing, of: sellerNameLabel)
            sellerAmountLabel.text = transaction.sellBalance?.amount.formattedWithSeparator
            
            return view
        }()
        
        stackView.addArrangedSubviews([
            // first part
            readyCheckMark,
            transactionCompletedLabel,
            transactionTimestampLabel,
            separator0,
            // second part
            amountLabel,
            burnedPercentLabel,
            buyerAvatarImageView,
            buyerNameLabel,
            buyerBalanceOrFriendIDLabel,
            separator1,
            // third part
            debitedFromLabel,
            blueBottomView
        ])
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 0, bottom: -16, right: 0))
        
        blueBottomView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 29)
        blueBottomView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: 29)
        
        // set up
        switch transaction.actionType {
        case .buy, .sell:
            buyerNameLabel.text = transaction.buyBalance!.name
            buyerBalanceOrFriendIDLabel.text = String(Double(transaction.buyBalance!.amount).currencyValueFormatted)
            buyerAvatarImageView.setAvatar(urlString: transaction.buyBalance?.avatarURL, namePlaceHolder: transaction.buyBalance?.name ?? Config.defaultSymbol)

        case .convert:
            buyerNameLabel.text = transaction.buyBalance!.name
            buyerBalanceOrFriendIDLabel.text = String(Double(transaction.buyBalance!.amount).currencyValueFormatted)
            if transaction.symbol.buy == Config.defaultSymbol {
                buyerAvatarImageView.image = UIImage(named: "CMN")
            } else {
                buyerAvatarImageView.setAvatar(urlString: transaction.buyBalance?.avatarURL, namePlaceHolder: transaction.buyBalance?.name ?? Config.defaultSymbol)
            }

        default:
            buyerNameLabel.text = transaction.friend?.name ?? Config.defaultSymbol
            buyerBalanceOrFriendIDLabel.text = transaction.friend?.id ?? Config.defaultSymbol
            buyerAvatarImageView.setAvatar(urlString: transaction.friend?.avatarURL, namePlaceHolder: transaction.friend?.name ?? Config.defaultSymbol)
        }
    }
    
    private func separatorWithIndex(_ index: Int) -> UIView {
        let view = UIView(height: 24)
        let hole1 = UIView(width: 24, height: 24, backgroundColor: parentColor, cornerRadius: 12)
        view.addSubview(hole1)
        hole1.autoPinEdge(toSuperviewEdge: .leading, withInset: -12)
        hole1.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        view.addSubview(dashLines[index])
        dashLines[index].autoPinEdge(.leading, to: .trailing, of: hole1, withOffset: 10)
        dashLines[index].autoAlignAxis(toSuperviewAxis: .horizontal)
        
        let hole2 = UIView(width: 24, height: 24, backgroundColor: parentColor, cornerRadius: 12)
        view.addSubview(hole2)
        hole2.autoPinEdge(toSuperviewEdge: .trailing, withInset: -12)
        hole2.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        hole2.autoPinEdge(.leading, to: .trailing, of: dashLines[index], withOffset: 10)
        
        return view
    }
}
