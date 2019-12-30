//
//  UserNameRulesView.swift
//  Commun
//
//  Created by Chung Tran on 12/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class UserNameRulesView: MyCardView {
    // MARK: - Subviews
    lazy var understoodButton = CommunButton.default(height: 50 * Config.heightRatio, label: "understood".localized().uppercaseFirst, isHuggingContent: false)
    lazy var closeButton = UIButton.close(size: 24)
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        
        addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView()
        
        let titleLabel = UILabel.with(text: "username must be".localized().uppercaseFirst, textSize: 17, weight: .semibold)
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
        
        let rulesText = """
        •  The number of characters must not exceed 32
        •  Uppercase letters in the username are not allowed
        •  Valid characters: letters, numbers, hyphen
        •  The hyphen character cannot be at the beginning or at the end of the username
        •  The user name may contain a "dot" character
        •  The presence of two "dot" characters in a row is not valid
        """
        
        let attributedString = NSMutableAttributedString(string: rulesText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8 * Config.heightRatio
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        let rulesLabel = UILabel.with(textSize: 15, textColor: .a5a7bd, numberOfLines: 0)
        rulesLabel.attributedText = attributedString
        
        addSubview(rulesLabel)
        rulesLabel.autoPinEdge(.top, to: .bottom, of: closeButton, withOffset: 13)
        rulesLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        rulesLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        addSubview(understoodButton)
        understoodButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 20), excludingEdge: .top)
        understoodButton.autoPinEdge(.top, to: .bottom, of: rulesLabel, withOffset: 20)
        
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        understoodButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
}
