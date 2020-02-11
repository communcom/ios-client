//
//  MyEmptyPlaceHolderView.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
    
    var buttonAction: (() -> Void)?
  
    // MARK: - Subviews
    lazy var emojiLabel = UILabel.with(text: "😿", textSize: .adaptive(width: 32.0))
    lazy var titleLabel = UILabel.with(text: "Nothing", textSize: .adaptive(width: 15.0), weight: .semibold)
    lazy var descriptionLabel = UILabel.with(text: "Nothing's here", textSize: .adaptive(width: 15.0), weight: .medium, textColor: #colorLiteral(red: 0.647, green: 0.655, blue: 0.741, alpha: 1))
    lazy var button = CommunButton.default(label: "retry")
    
    // MARK: - Initializers
    init(emoji: String? = nil, title: String, description: String?, buttonLabel: String? = nil, buttonAction: (() -> Void)? = nil) {
        self.emoji              =   emoji ?? "😿"
        self.title              =   title
        self.buttonLabel        =   buttonLabel
        self.buttonAction       =   buttonAction
        self.descriptionText    =   description

        super.init(frame: .zero)
        
        configureForAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Functions
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = .white
        cornerRadius = 10
        
        let containerView = UIView(forAutoLayout: ())
        addSubview(containerView)

        containerView.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 16.0))
        containerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(width: 16.0))
        containerView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        containerView.addSubview(emojiLabel)
        emojiLabel.autoPinEdge(toSuperviewEdge: .top)
        emojiLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: emojiLabel, withOffset: .adaptive(height: 10.0))
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: .adaptive(height: 5.0))
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        if let buttonLabel = buttonLabel {
            containerView.addSubview(button)
            button.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: .adaptive(height: 15.0))
            button.autoAlignAxis(toSuperviewAxis: .vertical)
            button.autoPinEdge(toSuperviewEdge: .bottom)
            button.setTitle(buttonLabel, for: .normal)
            button.addTarget(self, action: #selector(buttonDidTouch), for: .touchUpInside)
        } else {
            descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom)
        }
        
        setUp()
    }
    
    func setUp() {
        emojiLabel.text = emoji
        titleLabel.text = title
        descriptionLabel.text = descriptionText
    }
    
    // MARK: - Actions
    @objc func buttonDidTouch() {
        guard let action = buttonAction else {return}
        action()
    }
}
