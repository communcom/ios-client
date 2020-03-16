//
//  CreatePasswordVC.swift
//  Commun
//
//  Created by Chung Tran on 3/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreatePasswordVC: SignUpBaseVC {
    // MARK: - Properties
    let viewModel = CreatePasswordViewModel()
    
    // MARK: - Subviews
    lazy var textField: UITextField = {
        let tf = UITextField(width: 290, height: 56, backgroundColor: .f3f5fa, cornerRadius: 12)
        tf.font = .systemFont(ofSize: 17 * Config.heightRatio)
        tf.keyboardType = .alphabet
        tf.placeholder = "password".localized().uppercaseFirst
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
        tf.isSecureTextEntry = true
        
        let rightView = UIView(width: 44, height: 56)
        rightView.addSubview(showPasswordButton)
        showPasswordButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        showPasswordButton.autoAlignAxis(toSuperviewAxis: .vertical)
        tf.rightView = rightView
        tf.rightViewMode = .always
        return tf
    }()
    
    lazy var showPasswordButton: UIButton = {
        let button = UIButton(width: 44, height: 56, contentInsets: UIEdgeInsets(top: 21, left: 12, bottom: 21, right: 12))
        button.setImage(UIImage(named: "show-password"), for: .normal)
        button.addTarget(self, action: #selector(showPasswordDidTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        titleLabel.text = "create Password".localized().uppercaseFirst
        
    }
    
    override func bind() {
        super.bind()
        viewModel.isShowingPassword
            .subscribe(onNext: { (isShowingPassword) in
                self.textField.isSecureTextEntry = !isShowingPassword
                self.showPasswordButton.setImage(UIImage(named:(isShowingPassword ? "hide": "show") + "-password"), for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc func showPasswordDidTouch() {
        viewModel.isShowingPassword.accept(!viewModel.isShowingPassword.value)
    }
}
