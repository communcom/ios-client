//
//  CMWalletView.swift
//  Commun
//
//  Created by Chung Tran on 4/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMWalletView: MyView {
    // MARK: - Subviews
    lazy var contentView = UIView(cornerRadius: 16)
    lazy var imageContainerView: UIView = {
        let imageView = UIImageView(width: 19.69 * Config.widthRatio, height: 18.05 * Config.widthRatio)
        imageView.image = UIImage(named: "wallet-icon")
        
        let imageContainerView = UIView(width: 50 * Config.widthRatio, height: 50 * Config.widthRatio, backgroundColor: UIColor.white.withAlphaComponent(0.2), cornerRadius: 25 * Config.widthRatio)
        imageContainerView.addSubview(imageView)
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        return imageContainerView
    }()
    lazy var label = UILabel.with(numberOfLines: 0)
    lazy var nextButton: UIView = {
        let view = UIView(height: 35, backgroundColor: UIColor.white.withAlphaComponent(0.1), cornerRadius: 35 / 2)
        
        view.addSubview(nextButtonLabel)
        nextButtonLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16 * Config.widthRatio)
        nextButtonLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        let nextArrow = UIImageView(width: 7.5, height: 15, imageNamed: "next-arrow")
        nextArrow.tintColor = .white
        view.addSubview(nextArrow)
        nextArrow.autoAlignAxis(toSuperviewAxis: .horizontal)
        nextArrow.autoPinEdge(.leading, to: .trailing, of: nextButtonLabel, withOffset: 10 * Config.widthRatio)
        nextArrow.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16 * Config.widthRatio)
        
        return view
    }()
    lazy var nextButtonLabel: UILabel = {
        let label = UILabel.with(text: "wallet".localized().uppercaseFirst, textSize: 15 * Config.widthRatio, weight: .medium, textColor: .white)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    override func commonInit() {
        super.commonInit()
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
        stackView.addArrangedSubviews([
            imageContainerView,
            label,
            nextButton
        ])
    }
    
    func setUp(withError: Bool = false, balances: [ResponseAPIWalletGetBalance]? = nil) {
        nextButtonLabel.isHidden = false
        imageContainerView.isHidden = false
        if withError {
            imageContainerView.isHidden = true
            label.attributedText = NSMutableAttributedString()
                .text("loading failed".localized().uppercaseFirst, size: 17, weight: .medium, color: .white)
            nextButtonLabel.text = "retry".localized().uppercaseFirst
        } else if let balances = balances {
            var title = "equity USD Value".localized().uppercaseFirst
            var balance = "$ " + balances.equityUSDValue.currencyValueFormatted
            if UserDefaults.standard.bool(forKey: Config.currentEquityValueIsShowingCMN) {
                title = "equity Commun Value".localized().uppercaseFirst
                balance = balances.enquityCommunValue.currencyValueFormatted
            }
            label.attributedText = NSMutableAttributedString()
                .text(title, size: 12 * Config.widthRatio, weight: .semibold, color: .white)
                .text("\n")
                .text(balance, size: 20 * Config.widthRatio, weight: .semibold, color: .white)
            nextButtonLabel.text = "wallet".localized().uppercaseFirst
        } else {
            label.attributedText = NSMutableAttributedString()
                .text("loading...".localized().uppercaseFirst, size: 17, weight: .medium, color: .white)
            nextButtonLabel.isHidden = true
        }
    }
    
    func setUp(walletPrice: ResponseAPIWalletGetPrice, communityName: String) {
        nextButtonLabel.isHidden = false
        imageContainerView.isHidden = false

        label.attributedText = NSMutableAttributedString()
            .text(walletPrice.priceValue.string, size: 20, weight: .semibold, color: .white)
            .text(" ")
            .text(communityName.lowercased().uppercaseFirst, size: 12, weight: .semibold, color: UIColor.white.withAlphaComponent(0.7))
            .text("\n")
            .text("= 1 Commun", size: 12, weight: .semibold, color: UIColor.white.withAlphaComponent(0.7))
        
        nextButtonLabel.text = "get points".localized().uppercaseFirst
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if contentView.frame != .zero {
            // gradient
            let gradient = CAGradientLayer()
            gradient.frame = contentView.bounds
            gradient.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 0, y: 0.5)
            gradient.colors = [UIColor.appMainColor.cgColor, UIColor(hexString: "#99A8F8")!.inDarkMode(.appMainColor).cgColor]
            contentView.layer.insertSublayer(gradient, at: 0)

            // corner radius
            contentView.cornerRadius = 15
            
            // shadow
            addShadow(ofColor: UIColor.onlyLightModeShadowColor(UIColor(red: 106, green: 128, blue: 245)!), radius: 24, offset: CGSize(width: 0, height: 14), opacity: 0.4)
        }
    }
}
