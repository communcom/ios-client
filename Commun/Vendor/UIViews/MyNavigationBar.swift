//
//  MyNavigationBar.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class MyNavigationBar: MyView {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    lazy var backButton: UIButton = .back(tintColor: .white)
    lazy var titleLabel = UILabel.with(textSize: 15, weight: .bold)
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(backButton)
        backButton.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 4)
        backButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        addSubview(titleLabel)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        titleLabel.textAlignment = .center
        let constraint = titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    @objc func back() {
        parentViewController?.back()
    }
}
