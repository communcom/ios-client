//
//  EditRuleVC.swift
//  Commun
//
//  Created by Chung Tran on 9/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class EditRuleVC: BaseVerticalStackVC {
    let originalRule: ResponseAPIContentGetCommunityRule?
    var isEditMode: Bool { originalRule != nil }
    
    lazy var ruleNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 17, weight: .semibold)
        tf.textColor = .appMainColor
        return tf
    }()
    
    lazy var descriptionTextView: UITextView = {
        let tv = UITextView(forExpandable: ())
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17, weight: .semibold)
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    
    lazy var descriptionCountLabel: UILabel = {
        let label = UILabel.with(textSize: 13, textColor: .appGrayColor)
        return label
    }()
    
    init(rule: ResponseAPIContentGetCommunityRule? = nil) {
        self.originalRule = rule
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        
        title = isEditMode ? "edit rule".localized().uppercaseFirst : "add new rule".localized().uppercaseFirst
        
        stackView.spacing = 10
        stackView.addArrangedSubview(field(title: "rule name".localized().uppercaseFirst, editor: ruleNameTextField))
        
        let label = UILabel.with(text: "the rule name should be about community rules. After adding or editing, it will be automatically sent to voting".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .appGrayColor, numberOfLines: 0)
        stackView.addArrangedSubview(label.padding(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)))
        
        let descriptionField = field(title: "description".localized().uppercaseFirst + " (" + "optional".localized().uppercaseFirst + ")", editor: descriptionTextView)
        stackView.addArrangedSubview(descriptionField)
        
        descriptionField.addSubview(descriptionCountLabel)
        descriptionCountLabel.autoPinBottomAndTrailingToSuperView(inset: 16)
        
        ruleNameTextField.text = originalRule?.title
        ruleNameTextField.sendActions(for: .valueChanged)
        descriptionTextView.text = originalRule?.text
    }
    
    override func bind() {
        super.bind()
        
    }
    
    private func field(title: String, editor: UITextEditor) -> UIView {
        let stackView = UIStackView(axis: .vertical, spacing: 5, alignment: .leading, distribution: .fill)
        let titleLabel = UILabel.with(text: title, textSize: 12, weight: .medium, textColor: .appGrayColor)
        
        stackView.addArrangedSubviews([titleLabel, editor])
        editor.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32)
            .isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 7, trailing: 16)
        
        let field = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
        field.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        return field
    }
}
