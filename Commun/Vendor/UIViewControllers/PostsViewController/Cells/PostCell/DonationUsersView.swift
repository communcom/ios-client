//
//  DonationsView.swift
//  Commun
//
//  Created by Chung Tran on 4/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DonationUsersView: CMMessageView {
    lazy var userStackView = UsersStackView(height: 34)
    
    init() {
        super.init(frame: .zero)
        autoSetDimension(.height, toSize: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        contentView.addSubview(userStackView)
        userStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 5)
        userStackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        userStackView.autoPinEdge(toSuperviewEdge: .trailing)
    }
    
    func setUp(with donations: [ResponseAPIContentGetProfile]) {
        userStackView.setUp(with: donations)
    }
}
