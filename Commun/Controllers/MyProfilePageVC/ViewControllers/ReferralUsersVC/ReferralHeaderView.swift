//
//  ReferralHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReferralHeaderView: MyTableHeaderView {
    lazy var textField = UITextField(height: 44, cornerRadius: 22, font: .systemFont(ofSize: 15), placeholder: "enter code".localized().uppercaseFirst, autocorrectionType: .no, autocapitalizationType: .allCharacters, spellCheckingType: .no, rightView: sendButton)
    
    lazy var sendButton = CommunButton.default(height: 44, label: "send".localized().uppercaseFirst, isHuggingContent: true, isDisableGrayColor: true)
    
    lazy var learnMoreButton = UIButton(width: 18, height: 18)
    
    lazy var shareButton = CommunButton.default(height: 34, label: "share".localized().uppercaseFirst, isHuggingContent: false)
    lazy var copyButton = CommunButton.default(height: 34, label: "copy".localized().uppercaseFirst, isHuggingContent: false)
    
    override func commonInit() {
        super.commonInit()
        
        // Enter referall code
        let enterReferalContainerView = UIView(backgroundColor: .white, cornerRadius: 16)
        addSubview(enterReferalContainerView)
        enterReferalContainerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let haveAReferralCodeLabel = UILabel.with(text: "have a referral code?".localized().uppercaseFirst, textSize: 15, weight: .semibold)
        enterReferalContainerView.addSubview(haveAReferralCodeLabel)
        haveAReferralCodeLabel.autoPinTopAndLeadingToSuperView(inset: 16, xInset: 20)
        
        enterReferalContainerView.addSubview(textField)
        textField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 20, bottom: 16, right: 20), excludingEdge: .top)
        textField.autoPinEdge(.top, to: .bottom, of: haveAReferralCodeLabel, withOffset: 16)
        
        // Share & copy
        let containerView = UIView(backgroundColor: .white, cornerRadius: 16)
        addSubview(containerView)
        containerView.autoPinEdge(toSuperviewEdge: .leading)
        containerView.autoPinEdge(toSuperviewEdge: .trailing)
        containerView.autoPinEdge(.top, to: .bottom, of: enterReferalContainerView, withOffset: 20)
        
        let imageView = UIImageView(width: UIScreen.main.isSmall ? 100 : 140, height: UIScreen.main.isSmall ? 100 : 140, imageNamed: "referral-coin")
        containerView.addSubview(imageView)
        imageView.autoPinBottomAndTrailingToSuperView(inset: 0)
        
        let userIdLabel = UILabel.with(text: Config.currentUser?.id?.uppercased(), textSize: 24, weight: .semibold)
        
        containerView.addSubview(userIdLabel)
        userIdLabel.autoPinTopAndLeadingToSuperView(inset: 16, xInset: 20)
        
        learnMoreButton.setImage(UIImage(named: "referral-info"), for: .normal)
        containerView.addSubview(learnMoreButton)
        learnMoreButton.autoPinEdge(.leading, to: .trailing, of: userIdLabel, withOffset: 10)
        learnMoreButton.autoAlignAxis(.horizontal, toSameAxisOf: userIdLabel)
        
        let descriptionLabel = UILabel.with(text: "invite a friend and get 1 Commun".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd, numberOfLines: 0)
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: userIdLabel, withOffset: 6)
        descriptionLabel.autoPinEdge(.trailing, to: .leading, of: imageView)
        
        let buttonsStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .fillEqually)
        
        buttonsStackView.addArrangedSubviews([shareButton, copyButton])
        
        containerView.addSubview(buttonsStackView)
        buttonsStackView.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 10)
        buttonsStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        buttonsStackView.autoPinEdge(.trailing, to: .leading, of: imageView)
        
        buttonsStackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        let yourReferralsLabel = UILabel.with(text: "your referrals".localized().uppercaseFirst, textSize: 20, weight: .bold)
        addSubview(yourReferralsLabel)
        yourReferralsLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 16, right: 10), excludingEdge: .top)
        yourReferralsLabel.autoPinEdge(.top, to: .bottom, of: containerView, withOffset: 20)
        
        layoutIfNeeded()
        
        textField.delegate = self
    }
}

extension ReferralHeaderView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let string = string.uppercased()
        if string.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
            textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            textField.sendActions(for: .valueChanged)
        }
        return false
    }
}
