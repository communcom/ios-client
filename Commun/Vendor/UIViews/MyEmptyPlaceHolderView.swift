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
    var emoji: String {
        didSet {
            emojiLabel.text = emoji
        }
    }
    var title: String {
        didSet {
            titleLabel.text = title
        }
    }
    var descriptionText: String? {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }
    var buttonLabel: String? {
        didSet {
            button.setTitle(buttonLabel, for: .normal)
        }
    }
    var buttonAction: (()->Void)?
    
    // MARK: - Subviews
    lazy var emojiLabel = UILabel.with(text: "🙈", textSize: 32)
    lazy var titleLabel = UILabel.with(text: "Nothing", textSize: 15, weight: .bold)
    lazy var descriptionLabel = UILabel.descriptionLabel("Nothing's here", size: 15)
    lazy var button = CommunButton.default(label: "retry")
    
    // MARK: - Initializers
    init(emoji: String = "🙈", title: String, description: String?, buttonLabel: String? = nil, buttonAction: (()->Void)? = nil) {
        self.emoji = emoji
        self.title = title
        self.descriptionText = description
        self.buttonLabel = buttonLabel
        self.buttonAction = buttonAction
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
        
        containerView.addSubview(emojiLabel)
        emojiLabel.autoPinEdge(toSuperviewEdge: .top)
        emojiLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: emojiLabel, withOffset: 10)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        if let buttonLabel = buttonLabel
        {
            button.setTitle(buttonLabel, for: .normal)
            containerView.addSubview(button)
            button.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 16)
            button.autoAlignAxis(toSuperviewAxis: .vertical)
            button.addTarget(self, action: #selector(buttonDidTouch), for: .touchUpInside)
            button.autoPinEdge(toSuperviewEdge: .bottom)
        }
        else {
            descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom)
        }
        
        
        setUp()
    }
    
    func setUp() {
        emojiLabel.text = emoji
        titleLabel.text = title
        descriptionLabel.text = descriptionText
    }
    
    @objc func buttonDidTouch() {
        guard let action = buttonAction else {return}
        action()
    }
}
