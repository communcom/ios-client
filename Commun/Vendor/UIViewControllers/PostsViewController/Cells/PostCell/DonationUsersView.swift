//
//  DonationsView.swift
//  Commun
//
//  Created by Chung Tran on 4/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DonationUsersView: CMMessageView {
    lazy var userStackView: UsersStackView = {
        let stackView = UsersStackView(height: 34)
        stackView.textColor = .white
        return stackView
    }()
    
    lazy var donationsLabel = UILabel.with(textSize: 15, weight: .semibold, textColor: .white)
    
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
        
        contentView.addSubview(donationsLabel)
        donationsLabel.autoPinEdge(.leading, to: .trailing, of: userStackView, withOffset: 4)
        donationsLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        closeButton.autoPinEdge(.leading, to: .trailing, of: donationsLabel, withOffset: 16)
    }
    
    func setUp(with donations: [ResponseAPIContentGetProfile]) {
        userStackView.setUp(with: donations)
        donationsLabel.text = String(format: NSLocalizedString("donations-count", comment: ""), (donations.count - 3))
    }
}
