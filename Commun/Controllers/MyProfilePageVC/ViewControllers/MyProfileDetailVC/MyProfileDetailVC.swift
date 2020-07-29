//
//  MyProfileEditVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileDetailVC: MyProfileDetailFlowVC {
    // MARK: - Sections
    lazy var generalInfoView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var contactsView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var linksView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "my profile".localized().uppercaseFirst
    }
    
    override func setUpArrangedSubviews() {
        stackView.addArrangedSubviews([
            generalInfoView,
            contactsView,
            linksView
        ])
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.spacing = 20
    }
    
    // MARK: - Actions
    override func reloadData() {
        super.reloadData()
        updateGeneralInfo()
        updateContacts()
        updateLinks()
    }
    
    @objc func editGeneralInfoButtonDidTouch() {
        let vc = MyProfileEditGeneralInfoVC()
        show(vc, sender: nil)
    }
    
    @objc func editContactsButtonDidTouch() {
        let vc = MyProfileEditContactsVC()
        show(vc, sender: nil)
    }
    
    @objc func editLinksButtonDidTouch() {
        let vc = MyProfileEditLinksVC()
        show(vc, sender: nil)
    }
}
