//
//  MyProfileEditVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileDetailVC: BaseVerticalStackVC {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    
    // MARK: - Subviews
    var spacer: UIView { UIView(height: 2, backgroundColor: .appLightGrayColor)}
    
    // MARK: - Sections
    lazy var generalInfoView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var contactsView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    lazy var linksView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "my profile".localized().uppercaseFirst
        
        reloadData()
    }
    
    override func bind() {
        super.bind()
        UserDefaults.standard.rx.observe(Data.self, Config.currentUserGetProfileKey)
            .filter {$0 != nil}
            .map {$0!}
            .map {try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: $0)}
            .subscribe(onNext: { profile in
                self.profile = profile
                self.reloadData()
            })
            .disposed(by: disposeBag)
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
    private func reloadData() {
        updateGeneralInfo()
        updateContacts()
        updateLinks()
    }
}
