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
    }
}
