//
//  TransactionCompletedView.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 24.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift

let disposeBag = DisposeBag()

enum ActionButtonType {
    case home
    case wallet
    case `repeat`
}

class TransactionCompletedView: UIView {
    // MARK: - Properties
    let repeatButtonsArray = ["transfer", "convert"]
    private var isHistoryMode: Bool = false
    var mode: TransActionType!

    var buyerAvatarImageView: UIImageView = UIImageView.circle(size: .adaptive(width: 40.0), imageName: "tux")

    var boldLabels = [UILabel]() {
        didSet {
            boldLabels.forEach({ $0.tune(withText: "",
                                         textColor: .black,
                                         font: UIFont.systemFont(ofSize: .adaptive(width: 17.0), weight: .bold),
                                         alignment: .center,
                                         isMultiLines: false)})
        }
    }
    
    var semiboldLabels = [UILabel]() {
        didSet {
            semiboldLabels.forEach({ $0.tune(withText: "",
                                         textColor: .appGrayColor,
                                         font: UIFont.systemFont(ofSize: .adaptive(width: 12.0), weight: .semibold),
                                         alignment: .center,
                                         isMultiLines: false)})
        }
    }

    var transactionDateLabel: UILabel = UILabel()
    var transactionTitleLabel: UILabel = UILabel()

    var transactionAmountLabel: UILabel = {
        let transactionAmountLabelInstance = UILabel()
        transactionAmountLabelInstance.tune(withText: "",
                                            textColor: .black,
                                            font: UIFont.systemFont(ofSize: .adaptive(width: 20.0), weight: .bold),
                                            alignment: .right,
                                            isMultiLines: false)
        
        return transactionAmountLabelInstance
    }()

    var transactionCurrencyLabel: UILabel = {
        let transactionCurrencyLabelInstance = UILabel()
        transactionCurrencyLabelInstance.tune(withText: "",
                                              textColor: .appGrayColor,
                                              font: UIFont.systemFont(ofSize: .adaptive(width: 20.0), weight: .regular),
                                              alignment: .left,
                                              isMultiLines: false)
        
        return transactionCurrencyLabelInstance
    }()
        
    var buyerNameLabel: UILabel = UILabel()
    var buyerBalanceOrFriendIDLabel: UILabel = UILabel()
    var burnedPercentLabel: UILabel = UILabel()

    let sellerNameLabel = UILabel()
    var sellerAvatarImageView: UIImageView = UIImageView.circle(size: .adaptive(width: 30.0))

    var sellerAmountLabel: UILabel = {
        let sellerAmountLabelInstance = UILabel()
        sellerAmountLabelInstance.tune(withText: "",
                                       textColor: .black,
                                       font: UIFont.systemFont(ofSize: .adaptive(width: 15.0), weight: .bold),
                                       alignment: .right,
                                       isMultiLines: false)

        return sellerAmountLabelInstance
    }()
    
    let homeButton: UIButton = {
        let height: CGFloat = 50
        let homeButtonInstance = UIButton(width: .adaptive(width: 335.0),
                                          height: height,
                                          label: "home".localized().uppercaseFirst,
                                          labelFont: .systemFont(ofSize: 15, weight: .bold),
                                          backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1),
                                          textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
                                          cornerRadius: height / 2)
        homeButtonInstance.heightAnchor.constraint(equalToConstant: height).isActive = true
        return homeButtonInstance
    }()

    let backToWalletButton: UIButton = {
        let height: CGFloat = 50
        let backToWalletButtonInstance = UIButton(width: .adaptive(width: 335.0),
                                                  height: height,
                                                  label: "back to wallet".localized().uppercaseFirst,
                                                  labelFont: .systemFont(ofSize: 15, weight: .bold),
                                                  backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
                                                  textColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1),
                                                  cornerRadius: 25)
        backToWalletButtonInstance.heightAnchor.constraint(equalToConstant: height).isActive = true
        return backToWalletButtonInstance
    }()

    let repeatButton: UIButton = {
        let height: CGFloat = 50
        let repeatButtonInstance = UIButton(width: .adaptive(width: 335.0),
                                            height: height,
                                            label: "repeat".localized().uppercaseFirst,
                                            labelFont: .systemFont(ofSize: 15, weight: .bold),
                                            backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
                                            textColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1),
                                            cornerRadius: 25)
        repeatButtonInstance.heightAnchor.constraint(equalToConstant: height).isActive = true
        return repeatButtonInstance
    }()
    
    // MARK: - Class Initialization
    init(withMode mode: TransActionType) {
        self.mode = mode
        self.isHistoryMode = !["buy", "sell", "send"].contains(mode.rawValue)
        
        super.init(frame: .zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Functions
    private func setupView() {
        if isHistoryMode {
            addGesture()
        }
        
        backgroundColor = .clear
        boldLabels = [transactionTitleLabel, buyerNameLabel]
        semiboldLabels = [transactionDateLabel, buyerBalanceOrFriendIDLabel, burnedPercentLabel]
        
        // Add content view
        let contentView = UIView(forAutoLayout: ())
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        contentView.tag = 99
        
        // Add white view
        addSubview(contentView)

        contentView.autoPinEdge(toSuperviewEdge: .left)
        contentView.autoPinEdge(toSuperviewEdge: .right)

//        contentView.heightAnchor.constraint(equalToConstant: contentView.bounds.height).isActive = true
        
        // Add ready checkmark
        let readyCheckMarkButton = CommunButton.circle(size: .adaptive(width: 60.0),
                                                       backgroundColor: #colorLiteral(red: 0.3125971854, green: 0.8584119678, blue: 0.6879913807, alpha: 1),
                                                       tintColor: UIColor.white,
                                                       imageName: "icon-checkmark-white",
                                                       imageEdgeInsets: .zero)
        
        readyCheckMarkButton.isUserInteractionEnabled = false
        contentView.addSubview(readyCheckMarkButton)
        readyCheckMarkButton.autoAlignAxis(toSuperviewAxis: .vertical)
        readyCheckMarkButton.autoPinEdge(.top, to: .top, of: contentView, withOffset: .adaptive(height: 20.0))
        
        // Add shadow
        readyCheckMarkButton.addShadow(ofColor: #colorLiteral(red: 0.732, green: 0.954, blue: 0.886, alpha: 1),
                                       radius: .adaptive(height: 24.0),
                                       offset: CGSize(width: 0.0, height: .adaptive(height: 8.0)),
                                       opacity: 1.0)
        
        // Add titles
        let titlesStackView = UIStackView(axis: NSLayoutConstraint.Axis.vertical, spacing: .adaptive(height: 8.0))
        titlesStackView.alignment = .center
        titlesStackView.distribution = .fillProportionally
        
        contentView.addSubview(titlesStackView)
        titlesStackView.addArrangedSubviews([transactionTitleLabel, transactionDateLabel])
        titlesStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 44.0), vertical: .adaptive(height: 190.0)), excludingEdge: .bottom)
        
        // Draw first dashed line
        let dashedLine1 = UIView(frame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 291.0), height: .adaptive(height: 2.0))))
        draw(dashedLine: dashedLine1)
        contentView.addSubview(dashedLine1)
        dashedLine1.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 44.0), vertical: .adaptive(height: 330.0)), excludingEdge: .bottom)

        // Add Recipient data
        let recipientStackView = UIStackView(axis: NSLayoutConstraint.Axis.horizontal, spacing: .adaptive(width: 8.0))
        recipientStackView.alignment = .fill
        recipientStackView.distribution = .fill
        
        recipientStackView.addArrangedSubviews([transactionAmountLabel, transactionCurrencyLabel])
        
        burnedPercentLabel.text = String(format: "%.1f%% %@ 🔥", 0.1, "was burned".localized())

        let recipientDataStackView = UIStackView(axis: NSLayoutConstraint.Axis.vertical, spacing: .adaptive(height: 8.0))
        recipientDataStackView.alignment = .center
        recipientDataStackView.distribution = .fillProportionally
        
        contentView.addSubview(recipientDataStackView)
        recipientDataStackView.addArrangedSubviews([recipientStackView, burnedPercentLabel])
        recipientDataStackView.autoAlignAxis(toSuperviewAxis: .vertical)
        recipientDataStackView.autoPinEdge(.top, to: .bottom, of: dashedLine1, withOffset: .adaptive(height: 32))

        contentView.addSubview(buyerAvatarImageView)
        buyerAvatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        buyerAvatarImageView.autoPinEdge(.top, to: .bottom, of: dashedLine1, withOffset: .adaptive(height: 92.0))

        let namesStackView = UIStackView(axis: NSLayoutConstraint.Axis.vertical, spacing: .adaptive(height: 8.0))
        titlesStackView.alignment = .center
        titlesStackView.distribution = .fillProportionally
        
        contentView.addSubview(namesStackView)
        namesStackView.addArrangedSubviews([buyerNameLabel, buyerBalanceOrFriendIDLabel])
        namesStackView.autoAlignAxis(toSuperviewAxis: .vertical)
        namesStackView.autoPinEdge(.top, to: .bottom, of: buyerAvatarImageView, withOffset: .adaptive(height: 10.0))

        // Draw second dashed line
        if let dashedLine2 = dashedLine1.copyView() {
            draw(dashedLine: dashedLine2)
            contentView.addSubview(dashedLine2)
            dashedLine2.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 44.0), vertical: .adaptive(height: 218.0)), excludingEdge: .top)
        }
        
        // Add circles
        let leftTopCircle = createCircleView(withColor: isHistoryMode ? #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3) : #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), sideSize: .adaptive(width: 24.0))
        contentView.addSubview(leftTopCircle)
        leftTopCircle.autoPinTopAndLeadingToSuperView(inset: .adaptive(height: 154.0), xInset: .adaptive(width: -24.0 / 2))

        let leftBottomCircle = createCircleView(withColor: isHistoryMode ? #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3) : #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), sideSize: .adaptive(width: 24.0))
        contentView.addSubview(leftBottomCircle)
        leftBottomCircle.autoPinBottomAndLeadingToSuperView(inset: .adaptive(height: 97.0), xInset: .adaptive(width: -24.0 / 2))

        let rightTopCircle = createCircleView(withColor: isHistoryMode ? #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3) : #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), sideSize: .adaptive(width: 24.0))
        contentView.addSubview(rightTopCircle)
        rightTopCircle.autoPinTopAndTrailingToSuperView(inset: .adaptive(height: 154.0), xInset: .adaptive(width: -24.0 / 2))

        let rightBottomCircle = createCircleView(withColor: isHistoryMode ? #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3) : #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), sideSize: .adaptive(width: 24.0))
        contentView.addSubview(rightBottomCircle)
        rightBottomCircle.autoPinBottomAndTrailingToSuperView(inset: .adaptive(height: 97.0), xInset: .adaptive(width: -24.0 / 2))
        
        // Add 'Debited from' label
        let debitedFromLabel = UILabel()
        debitedFromLabel.tune(withText: "debited from".localized().uppercaseFirst,
                              textColor: .appGrayColor,
                              font: .systemFont(ofSize: .adaptive(width: 12.0), weight: .semibold),
                              alignment: .center,
                              isMultiLines: false)
        
        contentView.addSubview(debitedFromLabel)
        debitedFromLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        debitedFromLabel.autoPinEdge(.top, to: .bottom, of: dashedLine1, withOffset: .adaptive(height: 254.0))
        
        // Add blue bottom view
        let blueBottomView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 289.0), height: .adaptive(height: 50.0))))
        blueBottomView.backgroundColor = #colorLiteral(red: 0.558, green: 0.629, blue: 1, alpha: 1)
        blueBottomView.roundCorners(UIRectCorner(arrayLiteral: [.topLeft, .topRight]), radius: .adaptive(width: 15.0))
        
        contentView.addSubview(blueBottomView)
        blueBottomView.heightAnchor.constraint(equalToConstant: .adaptive(height: 50.0)).isActive = true
        blueBottomView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 46.0), vertical: 0.0), excludingEdge: .top)
        blueBottomView.autoPinEdge(.top, to: .bottom, of: debitedFromLabel, withOffset: 15)
        
        let senderStackView = UIStackView(axis: NSLayoutConstraint.Axis.horizontal, spacing: .adaptive(width: 10.0))
        senderStackView.alignment = .fill
        senderStackView.distribution = .fill
                
        senderStackView.addArrangedSubviews([sellerAvatarImageView, sellerNameLabel, sellerAmountLabel])
        sellerNameLabel.setContentHuggingPriority(249.0, for: NSLayoutConstraint.Axis.horizontal)
        
        blueBottomView.addSubview(senderStackView)
        senderStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 30.0), vertical: .adaptive(height: 20.0)))
        
        // Add action buttons
        let actionButtonsStackView = UIStackView(axis: NSLayoutConstraint.Axis.vertical, spacing: .adaptive(height: 10.0))
        actionButtonsStackView.alignment = .center
        actionButtonsStackView.distribution = .fillEqually
        
        self.addSubview(actionButtonsStackView)
        actionButtonsStackView.addArrangedSubviews(isHistoryMode ? [repeatButton] : [homeButton, backToWalletButton])
        actionButtonsStackView.autoPinEdge(.top, to: .bottom, of: contentView, withOffset: .adaptive(width: isHistoryMode ? 20.0 : 34.0))
        actionButtonsStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }
    
    private func addGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
    }

    func actions(_ sender: @escaping (ActionButtonType) -> Void) {
        // Home button
        homeButton.rx.tap
        .bind {
            print("Home button tapped")
            sender(.home)
        }
        .disposed(by: disposeBag)
        
        // Back to Wallet button
        backToWalletButton.rx.tap
        .bind {
            print("Back to Wallet button tapped")
            sender(.wallet)
        }
        .disposed(by: disposeBag)

        // Back to Wallet button
        repeatButton.rx.tap
        .bind {
            print("Repeat button tapped")
            sender(.repeat)
        }
        .disposed(by: disposeBag)
    }
    
    private func draw(dashedLine: UIView) {
        dashedLine.draw(lineColor: .e2e6e8,
                        lineWidth: .adaptive(height: 2.0),
                        startPoint: CGPoint(x: 0.0, y: .adaptive(height: 2.0) / 2),
                        endPoint: CGPoint(x: .adaptive(width: 291.0), y: .adaptive(height: 2.0) / 2),
                        withDashPattern: [10, 6])
        
        dashedLine.heightAnchor.constraint(equalToConstant: dashedLine.bounds.height).isActive = true
    }
    
    private func createCircleView(withColor color: UIColor, sideSize: CGFloat) -> UIView {
        let viewInstance = UIView(width: sideSize, height: sideSize, backgroundColor: color, cornerRadius: sideSize / 2)

        return viewInstance
    }
    
    func updateSellerInfo(fromTransaction transaction: Transaction) {
        if let sellBalance = transaction.sellBalance, let avatarURL = sellBalance.avatarURL {
            sellerAvatarImageView.setAvatar(urlString: avatarURL, namePlaceHolder: "icon-select-user-grey-cyrcle-default")
        } else {
            let communLogo = UIView.transparentCommunLogo(size: .adaptive(width: 30.0), backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2))
            sellerAvatarImageView.addSubview(communLogo)
            communLogo.autoAlignAxis(toSuperviewAxis: .vertical)
            communLogo.autoAlignAxis(toSuperviewAxis: .horizontal)
            communLogo.isUserInteractionEnabled = false
            sellerAvatarImageView.backgroundColor = .clear
        }

        sellerAmountLabel.text = transaction.sellBalance!.amount.formattedWithSeparator

        sellerNameLabel.tune(withText: transaction.sellBalance!.name,
                             textColor: .black,
                             font: UIFont.systemFont(ofSize: .adaptive(width: 15.0), weight: .semibold),
                             alignment: .left,
                             isMultiLines: false)
    }
    
    func updateBuyerInfo(fromTransaction transaction: Transaction) {
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
    
    func updateTransactionInfo(_ transaction: Transaction) {
        transactionTitleLabel.text = "transaction completed".localized().uppercaseFirst
        transactionDateLabel.text = transaction.operationDate.convert(toStringFormat: .transactionCompletedType)
        transactionAmountLabel.text = String(Double(transaction.amount).currencyValueFormatted)
        transactionCurrencyLabel.text = transaction.symbol.buy.fullName
 
        setColor(amount: transaction.amount)

        if isHistoryMode {
            repeatButton.isHidden = !repeatButtonsArray.contains(transaction.history?.meta.actionType ?? Config.defaultSymbol)
        }
    }

    private func setColor(amount: CGFloat) {
        transactionAmountLabel.text = (amount > 0 ? "+" : "-") + String(Double(abs(amount)).currencyValueFormatted)
        transactionAmountLabel.textColor = amount > 0 ? .appGreenColor : .black
        transactionCurrencyLabel.textColor = amount > 0 ? .appGreenColor : .black
    }
}
