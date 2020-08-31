//
//  MyProfileEditContactsVC.swift
//  Commun
//
//  Created by Chung Tran on 7/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class MyProfileEditContactsVC: MyProfileDetailFlowVC {
    // MARK: - Properties
    var originalContacts: ResponseAPIContentGetProfilePersonalLinks {profile?.personal?.links ?? ResponseAPIContentGetProfilePersonalLinks()}
    lazy var draftContacts = BehaviorRelay<ResponseAPIContentGetProfilePersonalLinks>(value: ResponseAPIContentGetProfilePersonalLinks())
    // MARK: - Subviews
    lazy var addContactButton: UIView = {
        let view = UIView(height: 57, backgroundColor: .white, cornerRadius: 10)
        let label = UILabel.with(text: "+ " + "add contact".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor)
        view.addSubview(label)
        label.autoCenterInSuperview()
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addContactButtonDidTouch)))
        return view
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "contacts".localized().uppercaseFirst
        
        reloadData()
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.spacing = 20
    }
    
    override func reloadData() {
        super.reloadData()
        stackView.removeArrangedSubviews()
        
        // MARK: - TODO: Contacts / Messengers
//        let contacts = profile?.personal?.contacts
//        if let whatsApp = contacts?.whatsApp {
//
//        }
//
//        if let telegram = contacts?.telegram {
//
//        }
//
//        if let wechat = contacts?.weChat {
//
//        }
        
        stackView.addArrangedSubview(addContactButton)
    }
    
    // MARK: - Actions
    @objc func addContactButtonDidTouch() {
        showCMActionSheet(title: "add contact".localized().uppercaseFirst, actions: [
            .customLayout(
                height: 50,
                title: "WeChat",
                spacing: 16,
                iconName: "wechat-icon",
                iconSize: 20,
                showIconFirst: true,
                bottomMargin: 10,
                handle: {
                    let vc = MyProfileAddContactVC(contactType: .weChat)
                    self.show(vc, sender: nil)
                }
            ),
            .customLayout(
                height: 50,
                title: "email",
                spacing: 16,
                iconName: "email-icon",
                iconSize: 20,
                showIconFirst: true,
                bottomMargin: 10,
                handle: {
                    
                }
            ),
            .customLayout(
                height: 50,
                title: "Facetime",
                spacing: 16,
                iconName: "facetime-icon",
                iconSize: 20,
                showIconFirst: true,
                bottomMargin: 10,
                handle: {
                    
                }
            ),
            .customLayout(
                height: 50,
                title: "Facebook messenger",
                spacing: 16,
                iconName: "facebook-messenger-icon",
                iconSize: 20,
                showIconFirst: true,
                bottomMargin: 10,
                handle: {
                    
                }
            ),
        ])
    }
}
