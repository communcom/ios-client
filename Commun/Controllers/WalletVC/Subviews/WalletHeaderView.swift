//
//  WalletHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 12/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class WalletHeaderView: MyTableHeaderView {
    // MARK: - Properties
    var stackViewTopConstraint: NSLayoutConstraint?
    var balances: [ResponseAPIWalletGetBalance]?
    var currentIndex: Int = 0 {
        didSet {
            if currentIndex == 0 {
                setUpWithCommunValue()
            } else {
                setUpWithCurrentBalance()
            }
        }
    }
    
    // MARK: - Subviews
    lazy var shadowView = UIView(forAutoLayout: ())
    lazy var contentView = UIView(backgroundColor: .appMainColor)
    
    lazy var titleLabel = UILabel.with(text: "Equity Value Commun", textSize: 15, weight: .semibold, textColor: .white)
    lazy var pointLabel = UILabel.with(text: "167 500.23", textSize: 30, weight: .bold, textColor: .white, textAlignment: .center)
    
    // MARK: - Balance
    lazy var balanceContainerView = UIView(forAutoLayout: ())
    lazy var communValueLabel = UILabel.with(text: "= 150 Commun", textSize: 12, weight: .semibold, textColor: .white)
    lazy var progressView = UIProgressView(forAutoLayout: ())
    lazy var availableHoldValueLabel = UILabel.with(text: "available".localized().uppercaseFirst + "/" + "hold".localized().uppercaseFirst, textSize: 12, textColor: .white)
    
    // MARK: - Buttons
    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal)
        stackView.addBackground(color: UIColor.white.withAlphaComponent(0.1), cornerRadius: 16)
        stackView.cornerRadius = 16
        return stackView
    }()
    
    lazy var sendButton = UIButton.circle(size: 30, backgroundColor: UIColor.white.withAlphaComponent(0.2), tintColor: .white, imageName: "upVote", imageEdgeInsets: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
    
    lazy var convertButton = UIButton.circle(size: 30, backgroundColor: UIColor.white.withAlphaComponent(0.2), tintColor: .white, imageName: "convert", imageEdgeInsets: UIEdgeInsets(inset: 6))
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        shadowView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 100 * Config.heightRatio)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        contentView.addSubview(pointLabel)
        pointLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        pointLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // balance
        balanceContainerView.addSubview(communValueLabel)
        communValueLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 5)
        communValueLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        balanceContainerView.addSubview(progressView)
        progressView.autoPinEdge(.top, to: .bottom, of: communValueLabel, withOffset: 32 * Config.heightRatio)
        progressView.autoPinEdge(toSuperviewEdge: .leading, withInset: 22 * Config.widthRatio)
        progressView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 22 * Config.widthRatio)
        
        let label = UILabel.with(textSize: 12, textColor: .white)
        label.attributedText = NSMutableAttributedString()
            .text("available".localized().uppercaseFirst, size: 12, color: .white)
            .text("/" + "hold".localized().uppercaseFirst, size: 12, color: UIColor.white.withAlphaComponent(0.5))
        
        balanceContainerView.addSubview(label)
        label.autoPinEdge(.leading, to: .leading, of: progressView)
        label.autoPinEdge(.top, to: .bottom, of: progressView, withOffset: 12)
        label.autoPinEdge(toSuperviewEdge: .bottom)
        
        balanceContainerView.addSubview(availableHoldValueLabel)
        availableHoldValueLabel.autoPinEdge(.top, to: .bottom, of: progressView, withOffset: 12)
        availableHoldValueLabel.autoPinEdge(.trailing, to: .trailing, of: progressView)
        
        // stackView
        contentView.addSubview(buttonsStackView)
        stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: pointLabel, withOffset: 30 * Config.heightRatio)
        buttonsStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16 * Config.widthRatio, bottom: 30 * Config.heightRatio, right: 16 * Config.widthRatio), excludingEdge: .top)
        
        buttonsStackView.addArrangedSubview(buttonContainerViewWithButton(sendButton, label: "send".localized().uppercaseFirst))
        buttonsStackView.addArrangedSubview(buttonContainerViewWithButton(convertButton, label: "convert".localized().uppercaseFirst))
        
        // pin bottom
        shadowView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 29)
        
        // initial setup
        setUpWithCommunValue()
    }
    
    func setUp(with balances: [ResponseAPIWalletGetBalance]) {
        self.balances = balances
        if currentIndex == 0 {
            setUpWithCommunValue()
        } else {
            setUpWithCurrentBalance()
        }
    }
    
    private func setUpWithCommunValue() {
        var point: Double = 0
        if let balances = balances {
            point = balances.reduce(0.0, { (result, balance) -> Double in
                var result = result
                result += balance.communValue
                return result
            })
        }
        // remove balanceContainerView if exists
        if balanceContainerView.isDescendant(of: contentView) {
            contentView.backgroundColor = .appMainColor
            balanceContainerView.removeFromSuperview()
            
            stackViewTopConstraint?.isActive = false
            stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: pointLabel, withOffset: 30 * Config.heightRatio)
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
        
        // set up
        titleLabel.text = "enquity Value Commun".localized().uppercaseFirst
        pointLabel.text = "\(point.currencyValueFormatted)"
        
    }
    
    private func setUpWithCurrentBalance() {
        guard let balances = balances,
            let balance = balances[safe: currentIndex]
        else {
            currentIndex = 0
            return
        }
        // add balanceContainerView
        if !balanceContainerView.isDescendant(of: contentView) {
            contentView.backgroundColor = UIColor(hexString: "#020202")
            contentView.addSubview(balanceContainerView)
            balanceContainerView.autoPinEdge(.top, to: .bottom, of: pointLabel)
            balanceContainerView.autoPinEdge(toSuperviewEdge: .leading)
            balanceContainerView.autoPinEdge(toSuperviewEdge: .trailing)
            
            stackViewTopConstraint?.isActive = false
            stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: balanceContainerView, withOffset: 30 * Config.heightRatio)
            
            UIView.transition(with: balanceContainerView, duration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        }
        
        // set up
        titleLabel.text = balance.name ?? "" + "balance".localized().uppercaseFirst
        pointLabel.text = "\(balance.balanceValue.currencyValueFormatted)"
        communValueLabel.text = "= \(balance.communValue.currencyValueFormatted)" + " " + "Commun"
        availableHoldValueLabel.attributedText = NSMutableAttributedString()
            .text("\(balance.balance)", size: 12, color: .white)
            .text("/\(balance.frozen ?? "0")", size: 12, color: UIColor.white.withAlphaComponent(0.5))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.roundCorners(UIRectCorner(arrayLiteral: .bottomLeft, .bottomRight), radius: 30 * Config.heightRatio)
        shadowView.addShadow(ofColor: UIColor(red: 106, green: 128, blue: 245)!, radius: 19, offset: CGSize(width: 0, height: 14), opacity: 0.3)
    }
    
    private func buttonContainerViewWithButton(_ button: UIButton, label: String) -> UIView {
        let container = UIView(forAutoLayout: ())
        container.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        button.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let label = UILabel.with(text: label, textSize: 12, textColor: .white)
        container.addSubview(label)
        label.autoPinEdge(.top, to: .bottom, of: button, withOffset: 7)
        label.autoAlignAxis(toSuperviewAxis: .vertical)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        return container
    }
    
    func startLoading() {
        contentView.showLoader()
    }
    
    func endLoading() {
        contentView.hideLoader()
    }
}
