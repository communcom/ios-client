//
//  CMTransactionBill.swift
//  Commun
//
//  Created by Chung Tran on 4/2/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMTransactionInfoView: MyView {
    // MARK: - Properties
    var transaction: Transaction
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, distribution: .fill)
    
    lazy var dashLines = [0, 1].compactMap {_ in UIView(height: 2)}
    
    lazy var buyerAvatarImageView = MyAvatarImageView(size: 40)
    
    lazy var buyerNameLabel = UILabel.with(textSize: 17, weight: .bold, textAlignment: .center)
    
    lazy var buyerBalanceOrFriendIDLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .appGrayColor, textAlignment: .center)
    
    lazy var blueBottomView = UIView(height: 30 + 36 * Config.heightRatio, backgroundColor: .appMainColor, cornerRadius: 16 * Config.heightRatio)
    
    // MARK: - Initializers
    init(transaction: Transaction) {
        self.transaction = transaction
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
        let readyCheckMark = CommunButton.circle(size: 60,
            backgroundColor: #colorLiteral(red: 0.3125971854, green: 0.8584119678, blue: 0.6879913807, alpha: 1),
            tintColor: UIColor.white,
            imageName: "icon-checkmark-white",
            imageEdgeInsets: .zero)
        readyCheckMark.addShadow(ofColor: #colorLiteral(red: 0.732, green: 0.954, blue: 0.886, alpha: 1), radius: 24.0, offset: CGSize(width: 0.0, height: 8.0), opacity: 1.0)
        
        let transactionCompletedLabel = UILabel.with(text: "transaction completed".localized().uppercaseFirst, textSize: 17, weight: .bold, textAlignment: .center)
        let transactionTimestampLabel = UILabel.with(text: transaction.operationDate.convert(toStringFormat: .transactionCompletedType), textSize: 12, weight: .semibold, textColor: .appGrayColor, textAlignment: .center)
        
        // second part
        let amount = transaction.amount
        let textColor: UIColor = amount > 0 ? .appGreenColor : .black
        let amountLabel = UILabel.with(textSize: 20)
        amountLabel.attributedString = NSMutableAttributedString()
            .text((amount > 0 ? "+" : "-") + String(Double(abs(amount)).currencyValueFormatted + " "), size: 20, weight: .semibold, color: textColor)
            .text(transaction.symbol.buy.fullName, size: 20, color: textColor)
        
        let burnedPercentLabel = UILabel.with(text: String(format: "%.1f%% %@ 🔥", 0.1, "was burned".localized()), textSize: 12, weight: .semibold, textColor: .appGrayColor, textAlignment: .center)
        
        // third part
        let debitedFromLabel = UILabel.with(text: "debited from".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: .appGrayColor)
        
        stackView.addArrangedSubviews([
            // first part
            readyCheckMark,
            transactionCompletedLabel,
            transactionTimestampLabel,
            dashLines[0],
            // second part
            amountLabel,
            burnedPercentLabel,
            buyerAvatarImageView,
            buyerNameLabel,
            buyerBalanceOrFriendIDLabel,
            dashLines[1],
            // third part
            debitedFromLabel,
            blueBottomView
        ])
        dashLines[0].widthAnchor.constraint(equalTo: stackView.widthAnchor)
            .isActive = true
        dashLines[1].widthAnchor.constraint(equalTo: stackView.widthAnchor)
            .isActive = true
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 0, bottom: -16 * Config.heightRatio, right: 0))
        
        blueBottomView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 29 * Config.heightRatio)
        blueBottomView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -29 * Config.heightRatio)
        
        // spacing
        stackView.setCustomSpacing(16 * Config.heightRatio, after: readyCheckMark)
        stackView.setCustomSpacing(8 * Config.heightRatio, after: transactionCompletedLabel)
        stackView.setCustomSpacing(25 * Config.heightRatio, after: transactionTimestampLabel)
        stackView.setCustomSpacing(25 * Config.heightRatio, after: dashLines[0])
        stackView.setCustomSpacing(8 * Config.heightRatio, after: amountLabel)
        stackView.setCustomSpacing(16 * Config.heightRatio, after: burnedPercentLabel)
        stackView.setCustomSpacing(10 * Config.heightRatio, after: buyerAvatarImageView)
        stackView.setCustomSpacing(8 * Config.heightRatio, after: buyerNameLabel)
        stackView.setCustomSpacing(25 * Config.heightRatio, after: buyerBalanceOrFriendIDLabel)
        stackView.setCustomSpacing(25 * Config.heightRatio, after: dashLines[1])
        stackView.setCustomSpacing(16 * Config.heightRatio, after: debitedFromLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for dash in dashLines {
            dash.draw(lineColor: .e2e6e8,
                lineWidth: 2.0,
                startPoint: CGPoint(x: 22, y: 1.0),
                endPoint: CGPoint(x: bounds.maxX - 22, y: 1.0),
                withDashPattern: [10, 6])
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let dashLineRects = dashLines.filter {$0.frame != .zero}.compactMap {$0.convert($0.bounds, to: self)}
        guard dashLineRects.count > 0 else {return}
        // Ensures to use the current background color to set the filling color
        backgroundColor?.setFill()
        UIRectFill(rect)
        
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        
        let radius: CGFloat = 12
        
        path.addLine(to: CGPoint(x: 0, y: dashLineRects[0].midY - radius))
        path.addArc(center: CGPoint(x: 0, y: dashLineRects[0].midY), radius: radius, startAngle: CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: true)
        
        path.addLine(to: CGPoint(x: 0, y: dashLineRects[1].midY - radius))
        path.addArc(center: CGPoint(x: 0, y: dashLineRects[1].midY), radius: radius, startAngle: CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: dashLineRects[1].midY + radius))
        path.addArc(center: CGPoint(x: rect.maxX, y: dashLineRects[1].midY), radius: radius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2, clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: dashLineRects[0].midY + radius))
        path.addArc(center: CGPoint(x: rect.maxX, y: dashLineRects[0].midY), radius: radius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        path.addLine(to: .zero)
        layer.path = path
        layer.fillRule = .evenOdd
        self.layer.mask = layer
    }
    
    // MARK: - Setup
    func setUp(buyBalance: Balance?, sellBalance: Balance?) {
        transaction.buyBalance = buyBalance
        transaction.sellBalance = sellBalance
        
        // set up
        switch transaction.actionType {
        case "buy", "sell":
            buyerNameLabel.text = transaction.buyBalance!.name
            buyerBalanceOrFriendIDLabel.text = String(Double(transaction.buyBalance!.amount).currencyValueFormatted)
            buyerAvatarImageView.setAvatar(urlString: transaction.buyBalance?.avatarURL)

        case "convert":
            buyerNameLabel.text = transaction.buyBalance!.name
            buyerBalanceOrFriendIDLabel.text = String(Double(transaction.buyBalance!.amount).currencyValueFormatted)
            if transaction.symbol.buy == Config.defaultSymbol {
                buyerAvatarImageView.image = UIImage(named: "CMN")
            } else {
                buyerAvatarImageView.setAvatar(urlString: transaction.buyBalance?.avatarURL)
            }

        default:
            buyerNameLabel.text = transaction.friend?.name ?? Config.defaultSymbol
            buyerBalanceOrFriendIDLabel.text = transaction.friend?.id ?? Config.defaultSymbol
            buyerAvatarImageView.setAvatar(urlString: transaction.friend?.avatarURL)
        }
        
        // Blue bottom view
        blueBottomView.removeSubviews()
        
        let imageView: UIView
        if let sellBalance = transaction.sellBalance, let avatarURL = sellBalance.avatarURL {
            let avatarImageView = MyAvatarImageView(size: 30.0)
            avatarImageView.setAvatar(urlString: avatarURL)
            imageView = avatarImageView
        } else {
            let communLogo = UIView.transparentCommunLogo(size: 30.0, backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2))
            imageView = communLogo
        }
        
        blueBottomView.addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 10 * Config.heightRatio)
        imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16 * Config.heightRatio)
        
        let sellerNameLabel = UILabel.with(text: transaction.sellBalance?.name, textSize: 15, weight: .semibold, textColor: .white)
        blueBottomView.addSubview(sellerNameLabel)
        sellerNameLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
        sellerNameLabel.autoAlignAxis(.horizontal, toSameAxisOf: imageView)
        sellerNameLabel.setContentHuggingPriority(249.0, for: .horizontal)
        sellerNameLabel.text = transaction.sellBalance?.name
        
        let sellerAmountLabel = UILabel.with(textSize: 15, weight: .bold, textColor: .white, textAlignment: .right)
        blueBottomView.addSubview(sellerAmountLabel)
        sellerAmountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16 * Config.heightRatio)
        sellerAmountLabel.autoAlignAxis(.horizontal, toSameAxisOf: imageView)
        sellerAmountLabel.autoPinEdge(.leading, to: .trailing, of: sellerNameLabel)
        sellerAmountLabel.text = transaction.sellBalance?.amount.formattedWithSeparator
        
        setNeedsDisplay()
    }
}
