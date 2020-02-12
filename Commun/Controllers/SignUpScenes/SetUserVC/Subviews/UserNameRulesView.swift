//
//  UserNameRulesView.swift
//  Commun
//
//  Created by Chung Tran on 12/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class UserNameRulesView: MyCardView {
    // MARK: - Properties
    lazy var actionButton = CommunButton.default(height: .adaptive(height: 50.0), label: "".localized().uppercaseFirst, isHuggingContent: false)
    lazy var closeButton = UIButton.close(size: .adaptive(width: 24.0))
    
    // MARK: - Custom Functions
    override func commonInit() {
        super.commonInit()
        
        addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView()
        
        let titleLabel = UILabel.with(text: viewParameters.title, textSize: .adaptive(width: 17.0), weight: .semibold)
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 20.0))
        titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
        
        let rulesText = """
        •  The number of characters must not exceed 32
        •  Uppercase letters in the username are not allowed
        •  Valid characters: letters, numbers, hyphen
        •  The hyphen character cannot be at the beginning or at the end of the username
        •  The user name may contain a "dot" character
        •  The presence of two "dot" characters in a row is not valid
        """
        
        let attributedString = NSMutableAttributedString(string: viewParameters == .user ? rulesText : viewParameters.note)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = .adaptive(height: .adaptive(height: 8.0))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        let rulesLabel = UILabel.with(textSize: .adaptive(width: 15.0), textColor: .a5a7bd, numberOfLines: 0)
        rulesLabel.attributedText = attributedString
        
        addSubview(rulesLabel)
        rulesLabel.autoPinEdge(.top, to: .bottom, of: closeButton, withOffset: .adaptive(height: 13.0))
        rulesLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 20.0))
        rulesLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(width: 20.0))
        
        addSubview(actionButton)
        actionButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 20), excludingEdge: .top)
        actionButton.autoPinEdge(.top, to: .bottom, of: rulesLabel, withOffset: .adaptive(height: 20.0))
        actionButton.setTitle(viewParameters.buttonTitle, for: .normal)
        
        actionButton.addTarget(self, action: #selector(openLink(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
}
