//
//  MyProfileEditVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileDetailVC: MyProfileDetailFlowVC, UserProfileInfoViewDelegate {
    // MARK: - Sections
    lazy var myProfileInfoView = MyProfileInfoView(forAutoLayout: ())
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "my profile".localized().uppercaseFirst
        myProfileInfoView.delegate = self
    }
    
    override func setUpArrangedSubviews() {
        stackView.addArrangedSubview(myProfileInfoView)
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.spacing = 20
    }
    
    // MARK: - Actions
    override func reloadData() {
        super.reloadData()
        guard let profile = profile else {return}
        myProfileInfoView.setUp(with: profile)
    }
    
    func editGeneralInfo() {
        let vc = MyProfileEditGeneralInfoVC()
        show(vc, sender: nil)
    }
    
    func editContacts() {
        let vc = MyProfileEditContactsVC()
        show(vc, sender: nil)
    }
    
    func editLinks() {
        let vc = MyProfileEditLinksVC()
        show(vc, sender: nil)
    }
}
