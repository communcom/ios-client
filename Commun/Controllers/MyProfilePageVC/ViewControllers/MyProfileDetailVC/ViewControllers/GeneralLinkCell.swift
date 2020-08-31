//
//  GeneralLinkCell.swift
//  Commun
//
//  Created by Chung Tran on 8/31/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol GeneralLinkCellDelegate: class {
    func linkCellOptionButtonDidTouch<T: UITextField>(_ linkCell: GeneralLinkCell<T>)
}

class GeneralLinkCell<T: UITextField>: MyView {
    lazy var label = UILabel.with(textSize: 15, weight: .semibold)
    lazy var icon = UIImageView(width: 20, height: 20)
    var textField: T!
    weak var delegate: GeneralLinkCellDelegate?
    lazy var stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fillEqually)
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .appWhiteColor
        cornerRadius = 10
        
        let titleView: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
            let optionButton = UIButton.option(tintColor: .appGrayColor, contentInsets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 0))
            optionButton.addTarget(self, action: #selector(optionButtonDidTouch), for: .touchUpInside)
            hStack.addArrangedSubviews([icon, label, optionButton])
            return hStack
        }()
        
        let textFieldWrapper: UIStackView = {
            let vStack = UIStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
            let label = UILabel.with(text: "username".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .appGrayColor)
            vStack.addArrangedSubviews([.spacer(height: 2, backgroundColor: .appLightGrayColor), label, textField])
            return vStack
        }()
        
        stackView.addArrangedSubviews([titleView, textFieldWrapper])
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 6, left: 16, bottom: 10, right: 16))
    }
    
    @objc func optionButtonDidTouch() {
        delegate?.linkCellOptionButtonDidTouch(self)
    }
}
