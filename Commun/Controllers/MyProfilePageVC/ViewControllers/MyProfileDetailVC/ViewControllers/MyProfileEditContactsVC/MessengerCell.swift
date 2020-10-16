//
//  MessengerCell.swift
//  Commun
//
//  Created by Chung Tran on 8/31/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MessengerCell: GeneralLinkCell<ContactTextField> {
    let messengerType: ResponseAPIContentGetProfilePersonalMessengers.MessengerType
    lazy var switcher = UISwitch()
    
    init(messengerType: ResponseAPIContentGetProfilePersonalMessengers.MessengerType) {
        self.messengerType = messengerType
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        defer {
            label.text = messengerType.rawValue.uppercaseFirst
            icon.image = UIImage(named: messengerType.rawValue.lowercased() + "-icon")
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        textField = ContactTextField(contactType: messengerType)
        super.commonInit()
        // add switch
        
        let switchWrapper: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
            let label = UILabel.with(text: "add to default contacts".localized().uppercaseFirst, textSize: 15, weight: .semibold, numberOfLines: 0)
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
            switcher.setContentHuggingPriority(.required, for: .horizontal)
            hStack.addArrangedSubviews([label, switcher])
            return hStack
        }()
        
        stackView.addArrangedSubview(switchWrapper)
        
        let spacer = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
        addSubview(spacer)
        spacer.autoPinEdge(toSuperviewEdge: .leading)
        spacer.autoPinEdge(toSuperviewEdge: .trailing)
        spacer.autoPinEdge(.bottom, to: .top, of: switchWrapper, withOffset: -7)
    }
}
