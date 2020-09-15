//
//  EditRuleVC.swift
//  Commun
//
//  Created by Chung Tran on 9/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class EditRuleVC: BaseVerticalStackVC {
    let descriptionLimit = 250
    let originalRule: ResponseAPIContentGetCommunityRule?
    var isEditMode: Bool { originalRule != nil }
    var newRuleHandler: ((ResponseAPIContentGetCommunityRule) -> Void)?
    
    lazy var saveButton = UIBarButtonItem(title: "save".localized().uppercaseFirst, style: .done, target: self, action: #selector(saveButtonDidTouch))
    
    lazy var ruleNameTextField: UITextView = {
        let tv = UITextView(forExpandable: ())
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17, weight: .semibold)
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.textColor = .appMainColor
        return tv
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ruleNameTextField.text = originalRule?.title
        descriptionTextView.text = originalRule?.text
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        
        saveButton.tintColor = .appBlackColor
        navigationItem.rightBarButtonItem = saveButton
        
        setLeftBarButton(imageName: "icon-back-bar-button-black-default", tintColor: .appBlackColor, action: #selector(askForSavingAndGoBack))
        
        title = isEditMode ? "edit rule".localized().uppercaseFirst : "add new rule".localized().uppercaseFirst
        
        stackView.spacing = 10
        stackView.addArrangedSubview(field(title: "rule name".localized().uppercaseFirst, editor: ruleNameTextField))
        
        let label = UILabel.with(text: "the rule name should be about community rules. After adding or editing, it will be automatically sent to voting".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .appGrayColor, numberOfLines: 0)
        stackView.addArrangedSubview(label.padding(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)))
        
        let descriptionField = field(title: "description".localized().uppercaseFirst + " (" + "optional".localized().uppercaseFirst + ")", editor: descriptionTextView)
        stackView.addArrangedSubview(descriptionField)
        
        descriptionField.addSubview(descriptionCountLabel)
        descriptionCountLabel.autoPinBottomAndTrailingToSuperView(inset: 16)
    }
    
    override func bind() {
        super.bind()
        
        let descriptionCount = descriptionTextView.rx.text.orEmpty.map {$0.count}.share()
            
        descriptionCount
            .map {"\($0)/\(self.descriptionLimit)"}
            .asDriver(onErrorJustReturn: "")
            .drive(descriptionCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        descriptionCount
            .map {$0 > self.descriptionLimit}
            .map {$0 ? UIColor.appRedColor: UIColor.appGrayColor}
            .asDriver(onErrorJustReturn: .appGrayColor)
            .drive(onNext: { (color) in
                self.descriptionCountLabel.textColor = color
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(descriptionCount, ruleNameTextField.rx.text)
            .map {_ in self.contentHasChanged()}
            .asDriver(onErrorJustReturn: false)
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
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
    
    // MARK: - Helpers
    private func contentHasChanged() -> Bool {
        if ruleNameTextField.text?.isEmpty == false {
            if descriptionTextView.text.count > descriptionLimit {return false}
            if !isEditMode {return true}
            return (ruleNameTextField.text != originalRule?.title) || (descriptionTextView.text != originalRule?.text)
        } else {
            return false
        }
    }
    
    // MARK: - Actions
    @objc func saveButtonDidTouch() {
        if isEditMode {
            var rule = originalRule
            rule?.title = ruleNameTextField.text
            rule?.text = descriptionTextView.text
            rule?.notifyChanged()
            back()
            return
        }
        
        backCompletion {
            self.newRuleHandler?(ResponseAPIContentGetCommunityRule.with(title: self.ruleNameTextField.text ?? "", text: self.descriptionTextView.text))
        }
    }
    
    @objc func askForSavingAndGoBack() {
        if contentHasChanged() {
            showAlert(title: "save".localized().uppercaseFirst, message: "do you want to save the changes you've made?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.saveButtonDidTouch()
                    return
                }
                self.back()
            }
        } else {
            back()
        }
    }
}
