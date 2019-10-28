//
//  MyEmptyPlaceHolderView.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout

class MyEmptyPlaceHolderView: MyView {
    // MARK: - Properties
    var title: String {
        didSet {
            setUp()
        }
    }
    var descriptionText: String? {
        didSet {
            setUp()
        }
    }
    
    // MARK: - Subviews
    lazy var monkeyLabel = UILabel.with(text: "🙈", textSize: 32)
    lazy var titleLabel = UILabel.with(text: "Nothing", textSize: 15, weight: .bold)
    lazy var descriptionLabel = UILabel.descriptionLabel("Nothing's here", size: 15)
    
    // MARK: - Initializers
    init(title: String, description: String?) {
        self.title = title
        self.descriptionText = description
        super.init(frame: .zero)
        configureForAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        cornerRadius = 10
        
        let containerView = UIView(forAutoLayout: ())
        addSubview(containerView)
        containerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        containerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        containerView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        containerView.addSubview(monkeyLabel)
        monkeyLabel.autoPinEdge(toSuperviewEdge: .top)
        monkeyLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: monkeyLabel, withOffset: 10)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom)
        
        setUp()
    }
    
    func setUp() {
        titleLabel.text = title
        descriptionLabel.text = descriptionText
    }
}
