//
//  LinkCell.swift
//  Commun
//
//  Created by Chung Tran on 7/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class LinkCell: GeneralLinkCell<LinkTextField> {
    let linkType: ResponseAPIContentGetProfilePersonalLinks.LinkType
    
    init(linkType: ResponseAPIContentGetProfilePersonalLinks.LinkType) {
        self.linkType = linkType
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        defer {
            label.text = linkType.rawValue.uppercaseFirst
            icon.image = UIImage(named: linkType.rawValue.lowercased() + "-icon")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        textField = LinkTextField(linkType: linkType)
        super.commonInit()
    }
}
