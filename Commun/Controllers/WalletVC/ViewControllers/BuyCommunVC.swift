//
//  BuyCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 1/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class BuyCommunVC: BaseViewController {
    // MARK: - Properties
    lazy var stackView = ContentHuggingScrollView(axis: .vertical)
    lazy var currencyAvatarImageView = MyAvatarImageView(size: 40)
    lazy var currencyNameLabel = UILabel.with(textSize: 15, weight: .medium)
    lazy var youSendTextField = UITextField.decimalPad()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "buy Commun".localized().uppercaseFirst
        view.backgroundColor = .f3f5fa
        
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewSafeArea()
        
        let youSendLabel = UILabel.with(text: "you send".localized().uppercaseFirst, textSize: 15, weight: .medium)
        stackView.contentView.addSubview(youSendLabel)
        youSendLabel.autoPinTopAndLeadingToSuperView(inset: 20, xInset: 26)
        
        // currency container
        let currencyContainerView: UIView = {
            let view = UIView(backgroundColor: .white, cornerRadius: 10)
            view.addSubview(self.currencyAvatarImageView)
            self.currencyAvatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            self.currencyAvatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
            
            view.addSubview(self.currencyNameLabel)
            self.currencyNameLabel.autoPinEdge(.leading, to: .trailing, of: self.currencyAvatarImageView, withOffset: 10)
            self.currencyNameLabel.autoAlignAxis(.horizontal, toSameAxisOf: self.currencyAvatarImageView)
            
            let dropdownButton = UIButton.circleGray(imageName: "drop-down")
            view.addSubview(dropdownButton)
            dropdownButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            dropdownButton.autoAlignAxis(.horizontal, toSameAxisOf: self.currencyAvatarImageView)
            
            let separator = UIView(height: 2, backgroundColor: .f3f5fa)
            view.addSubview(separator)
            separator.autoPinEdge(.top, to: .bottom, of: self.currencyAvatarImageView, withOffset: 16)
            separator.autoPinEdge(toSuperviewEdge: .leading)
            separator.autoPinEdge(toSuperviewEdge: .trailing)
            
            let amountLabel = UILabel.with(text: "amount".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd)
            view.addSubview(amountLabel)
            amountLabel.autoPinEdge(.top, to: .bottom, of: separator, withOffset: 10)
            amountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            
            view.addSubview(self.youSendTextField)
            self.youSendTextField.autoPinEdge(.top, to: .bottom, of: amountLabel, withOffset: 8)
            self.youSendTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
            
            return view
        }()
        
        stackView.contentView.addSubview(currencyContainerView)
        currencyContainerView.autoPinEdge(.top, to: .bottom, of: youSendLabel, withOffset: 10)
        currencyContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        currencyContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // pin bottom
        currencyContainerView.autoPinEdge(toSuperviewEdge: .bottom)
    }
}
