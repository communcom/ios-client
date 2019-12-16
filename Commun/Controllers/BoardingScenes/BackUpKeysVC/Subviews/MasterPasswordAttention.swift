//
//  MasterPasswordAttention.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 25.11.2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class MasterPasswordAttention: MyCardView {
    // MARK: - Properties
    var ignoreSavingAction: (()->Void)?
    
    // MARK: - Custom Functions
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        
        let closeButton = UIButton.close(size: 30 * Config.heightRatio)
        addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView(inset: 16 * Config.heightRatio, xInset: 20 * Config.heightRatio)
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        let imageView = UIImageView(width: 90, height: 90, imageNamed: "image-round-attention")
        addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 30 * Config.heightRatio)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let attentionLabel = UILabel.with(text: "attention".localized().uppercaseFirst, textSize: 30 * Config.heightRatio, weight: .bold)
        addSubview(attentionLabel)
        attentionLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 20 * Config.heightRatio)
        attentionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8 * Config.heightRatio
        paragraphStyle.alignment = .center
        
        let firstAStr = NSAttributedString(string: "We do not keep master passwords and have no opportunity to restore them.".localized().uppercaseFirst, attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.systemFont(ofSize: 17 * Config.heightRatio, weight: .semibold)])
        
        let firstDescriptionLabel = UILabel.with(textSize: 17 * Config.heightRatio, numberOfLines: 0, textAlignment: .center)
        firstDescriptionLabel.attributedText = firstAStr
        addSubview(firstDescriptionLabel)
        firstDescriptionLabel.autoPinEdge(.top, to: .bottom, of: attentionLabel, withOffset: 16 * Config.heightRatio)
        firstDescriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.heightRatio)
        firstDescriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.heightRatio)
        
        let secondAStr = NSAttributedString(string: "Unfortunately for our comfort, blockchain doesn’t allow us to restore passwords. It means that it’s every user’s responsibility to keep the password in a safe place and be able to access it anytime.\nWe strongly recommend you to save your password and make a copy of it.".localized().uppercaseFirst, attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.systemFont(ofSize: 17 * Config.heightRatio)])
        
        
        let secondDescriptionLabel = UILabel.with(textSize: 15 * Config.heightRatio, textColor: .a5a7bd, numberOfLines: 0, textAlignment: .center)
        secondDescriptionLabel.attributedText = secondAStr
        addSubview(secondDescriptionLabel)
        secondDescriptionLabel.autoPinEdge(.top, to: .bottom, of: firstDescriptionLabel, withOffset: 16 * Config.heightRatio)
        secondDescriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.heightRatio)
        secondDescriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.heightRatio)
        
        let backButton = CommunButton.default(height: 50, label: "back".localized().uppercaseFirst, isHuggingContent: false)
        addSubview(backButton)
        backButton.autoPinEdge(.top, to: .bottom, of: secondDescriptionLabel, withOffset: 30 * Config.heightRatio)
        backButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.heightRatio)
        backButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.heightRatio)
        
        backButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        let ignoreButton = CommunButton.default(height: 50, label: "continue without backup".localized().uppercaseFirst, isHuggingContent: false)
        ignoreButton.backgroundColor = .f3f5fa
        ignoreButton.setTitleColor(.appMainColor, for: .normal)
        addSubview(ignoreButton)
        ignoreButton.autoPinEdge(.top, to: .bottom, of: backButton, withOffset: 10)
        ignoreButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 20 * Config.heightRatio)
        ignoreButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20 * Config.heightRatio)
        
        ignoreButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20 * Config.heightRatio)
        
        ignoreButton.addTarget(self, action: #selector(continueButtonTapped(_:)), for: .touchUpInside)
        
    }

    
    // MARK: - Actions
    @objc func closeButtonTapped(_ sender: UIButton) {
        close()
    }
    
    @objc func continueButtonTapped(_ sender: UIButton) {
        close()
        ignoreSavingAction?()
    }
}
