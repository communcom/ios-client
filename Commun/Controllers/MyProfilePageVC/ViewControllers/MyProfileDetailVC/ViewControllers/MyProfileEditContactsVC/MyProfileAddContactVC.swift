//
//  MyProfileAddContactVC.swift
//  Commun
//
//  Created by Chung Tran on 7/27/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

enum ContactType: String {
    enum IdentifyType: String {
        case phoneNumber = "phone number"
        case username = "username"
        case link = "link"
    }

    case wechat, telegram, whatsapp
    var identifiedBy: IdentifyType {
        switch self {
        case .wechat:
            return .username
        case .telegram, .whatsapp:
            return .phoneNumber
        }
    }

}

class MyProfileAddContactVC: BaseVerticalStackVC {
    // MARK: - Properties
    let contactType: ContactType
    
    // MARK: - Subviews
    lazy var textField = ContactTextField(contactType: contactType)
    
    lazy var sendCodeButton: CommunButton = {
        let button = CommunButton.default(height: 50, label: "send confirmation code".localized().uppercaseFirst, isHuggingContent: false, isDisableGrayColor: true)
        button.addTarget(self, action: #selector(buttonSendCodeDidTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    init(contactType: ContactType) {
        self.contactType = contactType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    // MARK: - Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        textField.resignFirstResponder()
    }
    
    override func setUp() {
        super.setUp()
        title = contactType.rawValue
    }
    
    override func bind() {
        super.bind()
        textField.rx.isValid
            .bind(to: sendCodeButton.rx.isDisabled)
            .disposed(by: disposeBag)
    }
    
    override func setUpArrangedSubviews() {
        let field = infoField(title: contactType.rawValue, editor: textField)
        let label = UILabel.with(text: "That contact should be confirmed.\nWe will send you a 4-digits code to confirm it.", textSize: 12, weight: .semibold, textColor: .appGrayColor, numberOfLines: 0)
        
        stackView.addArrangedSubviews([field, label, sendCodeButton])
        field.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        sendCodeButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.spacing = 16
        stackView.alignment = .center
    }
    
    // MARK: - View builder
    private func infoField(title: String, editor: UITextEditor) -> UIView {
        let stackView = UIStackView(axis: .vertical, spacing: 8, alignment: .leading, distribution: .fill)
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
    
    // MARK: - Actions
    @objc func buttonSendCodeDidTouch() {
        let vc = MyProfileVerifyContactVC(contactType: contactType)
        show(vc, sender: nil)
    }
}
