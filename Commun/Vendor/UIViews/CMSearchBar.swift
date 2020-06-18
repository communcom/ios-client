//
//  CMSearchBar.swift
//  Commun
//
//  Created by Chung Tran on 6/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMSearchBar: MyView {
    // MARK: - Properties
    var placeholder = "search".localized().uppercaseFirst {
        didSet {
            textField.placeholder = placeholder
        }
    }
    var textFieldBgColor = UIColor.appLightGrayColor {
        didSet {
            textField.backgroundColor = textFieldBgColor
        }
    }
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .fill)
    
    lazy var textField: UITextField = {
        let textField = UITextField(backgroundColor: textFieldBgColor, placeholder: placeholder, showClearButton: true)
        
        // textField's leftView
        let magnifyingIconSize: CGFloat = 14
        let leftView = UIView(width: 34, height: magnifyingIconSize)
        let imageView = UIImageView(width: magnifyingIconSize, height: magnifyingIconSize, imageNamed: "search")
        leftView.addSubview(imageView)
        imageView.autoCenterInSuperview()
        
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        textField.clearButtonMode = .always
        textField.clearsOnBeginEditing = true
        
        return textField
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(label: "cancel".localized().uppercaseFirst, textColor: .appMainColor)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    // MARK: - Initializers
    init(textFieldBackgroundColor: UIColor = .appLightGrayColor) {
        super.init(frame: .zero)
        configureForAutoLayout()
        autoSetDimension(.height, toSize: 35)
        textFieldBgColor = textFieldBackgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        stackView.addArrangedSubviews([textField, cancelButton])
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if height > 0 {
            textField.cornerRadius = height / 2
        }
    }
}
