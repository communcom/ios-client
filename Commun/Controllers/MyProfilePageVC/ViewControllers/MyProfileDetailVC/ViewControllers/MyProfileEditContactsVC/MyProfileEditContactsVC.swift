//
//  MyProfileEditContactsVC.swift
//  Commun
//
//  Created by Chung Tran on 7/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileEditContactsVC: MyProfileDetailFlowVC {
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
        let contacts = profile?.personal?.contacts
        
        stackView.removeArrangedSubviews()
        
        if let whatsApp = contacts?.whatsApp {
            
        }
        
        if let telegram = contacts?.telegram {
            
        }
        
        if let wechat = contacts?.weChat {
            
        }
        
        stackView.addArrangedSubview(addContactButton)
    }
    
    // MARK: - Actions
    @objc func addContactButtonDidTouch() {
        showCommunActionSheet(title: "add contact".localized().uppercaseFirst, actions: [
            CommunActionSheet.Action(
                title: "WeChat",
                icon: UIImage(named: "wechat-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    let vc = MyProfileAddContactVC(contact: .weChat)
                    self.show(vc, sender: nil)
                }
            ),
            CommunActionSheet.Action(
                title: "email".localized().uppercaseFirst,
                icon: UIImage(named: "email-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    
                }
            ),
            CommunActionSheet.Action(
                title: "Facetime",
                icon: UIImage(named: "facetime-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    
                }
            ),
            CommunActionSheet.Action(
                title: "Facebook messenger",
                icon: UIImage(named: "facebook-messenger-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    
                }
            )
        ])
    }
}
