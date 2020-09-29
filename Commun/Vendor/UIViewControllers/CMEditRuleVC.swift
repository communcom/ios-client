//
//  CMEditRuleVC.swift
//  Commun
//
//  Created by Chung Tran on 9/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class CMEditRuleVC: BaseVerticalStackVC {
    let descriptionLimit = 250
    let originalRule: ResponseAPIContentGetCommunityRule?
    var isEditMode: Bool { originalRule != nil }
    var updateRuleHandler: ((ResponseAPIContentGetCommunityRule) -> Void)?
    var newRuleHandler: ((ResponseAPIContentGetCommunityRule) -> Void)?
    
    lazy var saveBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "save".localized().uppercaseFirst, style: .done, target: self, action: #selector(saveButtonDidTouch))
        button.isEnabled = false
        button.tintColor = .appBlackColor
        return button
    }()
    
    lazy var ruleNameTextField: UITextView = {
        let tv = UITextView(forExpandable: ())
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17, weight: .semibold)
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
    
    lazy var saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst, cornerRadius: 25, isHuggingContent: false)
        .onTap(self, action: #selector(saveButtonDidTouch))
    
    required init(rule: ResponseAPIContentGetCommunityRule? = nil) {
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
    
    private var customized = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !customized {
            if isBeingPresented {
                scrollView.removeConstraintToSuperView(withAttribute: .top)
                
                let headerStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
                let titleLabel = UILabel.with(text: (isEditMode ? "edit rule" : "new rule").localized().uppercaseFirst, textSize: 17, weight: .semibold)
                let closeButton = UIButton.close()
                    .onTap(self, action: #selector(askForSavingAndGoBack))
                
                headerStackView.addArrangedSubviews([titleLabel, .spacer(), closeButton])
                
                view.addSubview(headerStackView)
                headerStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10), excludingEdge: .bottom)
                headerStackView.autoPinEdge(.bottom, to: .top, of: scrollView, withOffset: -30)
                
                // presented
                scrollView.removeConstraintToSuperView(withAttribute: .bottom)
                
                view.addSubview(saveButton)
                saveButton.autoPinEdge(.top, to: .bottom, of: scrollView)
                saveButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
                saveButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
                saveButton.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 16)
            } else if isMovingToParent {
                // showed
                navigationItem.rightBarButtonItem = saveBarButton
                setLeftBarButton(imageName: "icon-back-bar-button-black-default", tintColor: .appBlackColor, action: #selector(askForSavingAndGoBack))
                title = isEditMode ? "edit rule".localized().uppercaseFirst : "add new rule".localized().uppercaseFirst
                
                let descriptionCount = descriptionTextView.rx.text.orEmpty.map {$0.count}
                Observable.merge(descriptionCount.map {_ in ()}, ruleNameTextField.rx.text.map {_ in ()})
                    .map {_ in self.contentHasChanged()}
                    .asDriver(onErrorJustReturn: false)
                    .drive(saveBarButton.rx.isEnabled)
                    .disposed(by: disposeBag)
            }
            customized = true
        }
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        
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
    func contentHasChanged() -> Bool {
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
        backCompletion {
            if self.isEditMode {
                guard var rule = self.originalRule else {return}
                rule.title = self.ruleNameTextField.text ?? ""
                rule.text = self.descriptionTextView.text
                self.updateRuleHandler?(rule)
            } else {
                self.newRuleHandler?(ResponseAPIContentGetCommunityRule.with(title: self.ruleNameTextField.text ?? "", text: self.descriptionTextView.text))
            }
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
