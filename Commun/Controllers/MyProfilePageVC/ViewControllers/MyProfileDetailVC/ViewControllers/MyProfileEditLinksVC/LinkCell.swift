//
//  LinkCell.swift
//  Commun
//
//  Created by Chung Tran on 7/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol LinkCellDelegate: class {
    func linkCellOptionButtonDidTouch(_ linkCell: LinkCell)
}

class LinkCell: MyView {
    let contactType: ResponseAPIContentGetProfilePersonal.LinkType
    lazy var label = UILabel.with(text: contactType.rawValue.uppercaseFirst, textSize: 15, weight: .semibold)
    lazy var icon = UIImageView(width: 20, height: 20, imageNamed: contactType.rawValue + "-icon")
    lazy var textField = ContactTextField(contactType: contactType)
    weak var delegate: LinkCellDelegate?
    
    init(contactType: ResponseAPIContentGetProfilePersonal.LinkType) {
        self.contactType = contactType
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .appWhiteColor
        cornerRadius = 10
        let vStack = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fillEqually)
        
        let titleView: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
            let optionButton = UIButton.option(tintColor: .appBlackColor, contentInsets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 0))
            optionButton.addTarget(self, action: #selector(optionButtonDidTouch), for: .touchUpInside)
            hStack.addArrangedSubviews([icon, label, optionButton])
            return hStack
        }()
        
        let textFieldWrapper: UIStackView = {
            let vStack = UIStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
            let label = UILabel.with(text: contactType.identifiedBy.rawValue.localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .appGrayColor)
            vStack.addArrangedSubviews([label, textField])
            return vStack
        }()
        
        vStack.addArrangedSubviews([titleView, textFieldWrapper])
        
        addSubview(vStack)
        vStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 6, left: 16, bottom: 10, right: 16))
        
        let spacer = UIView(height: 2, backgroundColor: .appLightGrayColor)
        addSubview(spacer)
        spacer.autoAlignAxis(toSuperviewAxis: .horizontal)
        spacer.autoPinEdge(toSuperviewEdge: .leading)
        spacer.autoPinEdge(toSuperviewEdge: .trailing)
    }
    
    @objc func optionButtonDidTouch() {
        delegate?.linkCellOptionButtonDidTouch(self)
    }
}
