//
//  CreateCommunityConfirmVC.swift
//  Commun
//
//  Created by Chung Tran on 9/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CreateCommunityConfirmVC: BaseVerticalStackVC, CreateCommunityVCType {
    let isDataValid = BehaviorRelay<Bool>(value: false)
    
    lazy var checkBox = CMCheckbox(width: 24, height: 24, cornerRadius: 6)
        .huggingContent(axis: .horizontal)
        .onTap(self, action: #selector(checkBoxDidTouch))
    
    override func setUp() {
        super.setUp()
        stackView.alignment = .center
        stackView.spacing = 30
        
        checkBox.isSelected = false
        
        let label = UILabel.with(textSize: 15, numberOfLines: 0, textAlignment: .center)
        
        let aStr = NSMutableAttributedString()
            .text("after pressing \"Create community\" button below, tokens will be debited from your wallet and next time you will need at least 3 votes from community leaders to make any changes in community settings.\nIf you want to make changes now — go back and do it before saving.".localized().uppercaseFirst, size: 15)
        
        aStr.addAttribute(.foregroundColor, value: UIColor.appMainColor, range: aStr.nsRangeOfText("\"" + "create community".localized().uppercaseFirst + "\""))
        aStr.addAttribute(.foregroundColor, value: UIColor.appMainColor, range: aStr.nsRangeOfText("3 votes from community leaders".localized()))
            
        label.attributedText = aStr
        let spacer = UIView.spacer(height: 2, backgroundColor: .e2e6e8)
        
        let checkBoxStackView: UIStackView = {
            let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .top, distribution: .fill)
            let label = UILabel.with(text: "i understand that after saving of all changes in current community, I’ll need at least 3 leaders in  current community to make changes next time.".localized().uppercaseFirst, textSize: 15, numberOfLines: 0)
                .onTap(self, action: #selector(checkBoxDidTouch))
            stackView.addArrangedSubviews([checkBox, label])
            return stackView
        }()
        stackView.addArrangedSubviews([
            UIImageView(width: 120, height: 120, cornerRadius: 60, imageNamed: "create-community-confirm"),
            label,
            spacer,
            checkBoxStackView
        ])
        label.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
        spacer.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
        checkBoxStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
    }
    
    @objc func checkBoxDidTouch() {
        checkBox.isSelected.toggle()
        isDataValid.accept(checkBox.isSelected)
    }
}
