//
//  CreateCommunityGettingStartedVC.swift
//  Commun
//
//  Created by Chung Tran on 9/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreateCommunityGettingStartedVC: BottomFlexibleHeightVC {
    lazy var titleLabel = UILabel.with(text: "create community".localized().uppercaseFirst, textSize: 17, weight: .semibold)
    lazy var continueButton = CommunButton.default(height: 50, label: "continue".localized().uppercaseFirst, cornerRadius: 25, isHuggingContent: false)
    lazy var communValueLabel = UILabel.with(textSize: 13, numberOfLines: 0)
    lazy var buyButton: UIButton = {
        let button = UIButton(height: 35, label: "+ \("buy".localized().uppercaseFirst)", backgroundColor: .appLightGrayColor, textColor: .appMainColor, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    override var headerStackViewEdgeInsets: UIEdgeInsets {
        var insets = super.headerStackViewEdgeInsets
        insets.top = 30
        insets.left = 16
        insets.right = 16
        return insets
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        
        headerStackView.insertArrangedSubview(titleLabel, at: 0)
        
        let stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .fill)
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10), excludingEdge: .bottom)
        
        stackView.addArrangedSubviews([
            createFirstSection(),
            createSecondSection()
        ])
        
        scrollView.contentView.addSubview(continueButton)
        continueButton.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: 16)
        continueButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
    }
    
    override func bind() {
        super.bind()
        BalancesViewModel.ofCurrentUser
            .items.map {$0.first(where: {$0.symbol == Config.defaultSymbol})}
            .filter {$0 != nil}.map {$0!}
            .map {$0.communValue}
            .subscribe(onNext: { (value) in
                self.communValueLabel.attributedText = NSMutableAttributedString()
                    .text("total balance Commun".localized().uppercaseFirst, size: 13, weight: .semibold, color: .appGrayColor)
                    .text("\n")
                    .text(value.formattedWithSeparator, size: 15, weight: .medium)
                
                self.continueButton.isEnabled = value > 10000
            })
            .disposed(by: disposeBag)
    }
    
    private func createFirstSection() -> UIView {
        let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 16)
        
        let topStackView: UIStackView = {
            let stackView = UIStackView(axis: .vertical, spacing: 24, alignment: .center, distribution: .fill)
            let label = UILabel.with(weight: .semibold, numberOfLines: 0, textAlignment: .center)
            label.attributedText = NSMutableAttributedString()
                .text("you need".localized().uppercaseFirst, size: 17, weight: .semibold)
                .text(" ".localized().uppercaseFirst, size: 17, weight: .semibold)
                .text("10 000 Commun ", size: 17, weight: .semibold, color: .appMainColor)
                .text("tokens".localized(), size: 17, weight: .semibold, color: .appMainColor)
                .text("\n")
                .text("to create a community".localized().uppercaseFirst, size: 17, weight: .semibold)
            
            stackView.addArrangedSubview(UIImageView(width: 75, height: 64, imageNamed: "create-community-icon"))
            stackView.addArrangedSubview(label)
            return stackView
        }()
        
        view.addSubview(topStackView)
        topStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 30, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        let separator = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
        view.addSubview(separator)
        separator.autoPinEdge(.top, to: .bottom, of: topStackView, withOffset: 30)
        separator.autoPinEdge(toSuperviewEdge: .leading)
        separator.autoPinEdge(toSuperviewEdge: .trailing)
        
        let bottomStackView: UIStackView = {
            let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            let logo = UIImageView.createCircleCommunLogo(side: 40)
            
            stackView.addArrangedSubviews([logo, communValueLabel, buyButton])
            return stackView
        }()
        
        view.addSubview(bottomStackView)
        bottomStackView.autoPinEdge(.top, to: .bottom, of: separator, withOffset: 12)
        bottomStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16), excludingEdge: .top)
        return view
    }
    
    private func createSecondSection() -> UIView {
        let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 16)
        
        let stackView: UIStackView = {
            let stackView = UIStackView(axis: .vertical, spacing: 20, alignment: .fill, distribution: .fill)
            
            let titleLabel = UILabel.with(text: "after creating a community".localized().uppercaseFirst, textSize: 15, weight: .medium, textAlignment: .center)
            let createContent: ((NSAttributedString) -> UIStackView) = { aString in
                let stackView = UIStackView(axis: .horizontal, spacing: 14, alignment: .center, distribution: .fill)
                stackView.addArrangedSubview(UIImageView(width: 6, height: 6, imageNamed: "create-community-dot"))
                let label = UILabel.with(textSize: 15, numberOfLines: 0)
                label.attributedText = aString
                stackView.addArrangedSubview(label)
                return stackView
            }
            let firstPoint = createContent(
                NSMutableAttributedString()
                    .text("1000 Commun " + "tokens".localized(), size: 15, weight: .semibold, color: .appMainColor)
                    .text("\n")
                    .text("will be burned for public goods".localized().uppercaseFirst + " 🔥", size: 15, color: .appGrayColor)
            )
            
            let secondPoint = createContent(
                NSMutableAttributedString()
                    .text("367 961.112 " + "points".localized(), size: 15, weight: .semibold, color: .appMainColor)
                    .text("\n")
                    .text("will be sent to the bounty service".localized().uppercaseFirst + " 🔥", size: 15, color: .appGrayColor)
            )
            
            let thirdPoint = createContent(
                NSMutableAttributedString()
                    .text("3 415 329.619 " + "points".localized(), size: 15, weight: .semibold, color: .appMainColor)
                    .text("\n")
                    .text("will be transferred to your wallet".localized().uppercaseFirst + " 🔥", size: 15, color: .appGrayColor)
            )
            
            stackView.addArrangedSubviews([
                titleLabel,
                firstPoint,
                secondPoint,
                thirdPoint
            ])
            
            return stackView
        }()
        
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))
        
        return view
    }
}
