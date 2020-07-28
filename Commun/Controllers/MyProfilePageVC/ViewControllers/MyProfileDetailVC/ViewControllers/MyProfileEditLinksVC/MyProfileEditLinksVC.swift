//
//  MyProfileEditLinksVC.swift
//  Commun
//
//  Created by Chung Tran on 7/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class MyProfileEditLinksVC: BaseVerticalStackVC {
    // MARK: - Properties
    lazy var links = BehaviorRelay<ResponseAPIContentGetProfileContact?>(value: nil)
    
    // MARK: - Subviews
    lazy var addLinkButton: UIView = {
        let view = UIView(height: 57, backgroundColor: .white, cornerRadius: 10)
        let label = UILabel.with(text: "+ " + "add link".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor)
        view.addSubview(label)
        label.autoCenterInSuperview()
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addLinkButtonDidTouch)))
        return view
    }()
    
    // MARK: - Methods
    override func setUp() {
        // parse current data
        if let data = UserDefaults.standard.data(forKey: Config.currentUserGetProfileKey),
            let profile = try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: data)
        {
            self.links.accept(profile.personal?.contacts)
        }
        
        super.setUp()
        title = "contacts".localized().uppercaseFirst
    }
    
    override func bind() {
        super.bind()
        
        links.filter {$0 != nil}.map {$0!}
            .subscribe(onNext: { (links) in
                self.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.spacing = 20
    }
    
    func reloadData() {
        stackView.removeArrangedSubviews()
        
        
        if let whatsApp = links.value?.facebook {
            
        }
        
        stackView.addArrangedSubview(addLinkButton)
    }
    
    // MARK: - Actions
    @objc func addLinkButtonDidTouch() {
        showCommunActionSheet(title: "add contact".localized().uppercaseFirst, actions: [
            CommunActionSheet.Action(
                title: "Instagram",
                icon: UIImage(named: "sign-up-with-instagram"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    
                }
            ),
            CommunActionSheet.Action(
                title: "Linkedin".localized().uppercaseFirst,
                icon: UIImage(named: "linkedin-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    
                }
            ),
            CommunActionSheet.Action(
                title: "Github",
                icon: UIImage(named: "github-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    
                }
            ),
            CommunActionSheet.Action(
                title: "Dribbble",
                icon: UIImage(named: "dribble-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    
                }
            )
        ])
    }
}
