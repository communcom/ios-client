//
//  PasswordsVC.swift
//  Commun
//
//  Created by Chung Tran on 6/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class PasswordsVC: BaseViewController {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        title = "passwords".localized().uppercaseFirst
        
        // backButton
        setLeftNavBarButtonForGoingBack()

        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        scrollView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard()
        
        // stackView
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))
        
        // password
        stackView.addArrangedSubviews([
            secretFieldWithTitle("password".localized().uppercaseFirst),
            secretFieldWithTitle("owner".localized().uppercaseFirst),
            secretFieldWithTitle("active".localized().uppercaseFirst)
        ])
    }
    
    private func secretFieldWithTitle(_ title: String) -> UIView {
        let view = UIView(backgroundColor: .white, cornerRadius: 10)
        let stackView = UIStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)
        view.addSubview(stackView)
        
        let titleLabel = UILabel.with(text: title, textSize: 12, weight: .medium, textColor: .appGrayColor)
        
        let passwordField = UIView(backgroundColor: .clear)
        
        let passwordLabel = UILabel.with(text: "••••••••••••••••••••••••••••", textSize: 17, weight: .medium)
        let showPasswordButton = UIButton(width: 24, height: 16)
        showPasswordButton.setImage(UIImage(named: "show-password"), for: .normal)
        
        passwordField.addSubview(passwordLabel)
        passwordLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        passwordField.addSubview(showPasswordButton)
        showPasswordButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)
        passwordLabel.autoPinEdge(.trailing, to: .leading, of: showPasswordButton, withOffset: -8)
        
        stackView.addArrangedSubviews([titleLabel, passwordField])
        
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        
        return view
    }
}
