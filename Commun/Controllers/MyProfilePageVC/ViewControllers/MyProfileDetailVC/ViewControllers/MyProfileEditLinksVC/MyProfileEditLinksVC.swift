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
    lazy var textField: UITextField = {
        let tf = UITextField()
//        tf.placeholder = ("your " + links.idType.rawValue).localized().uppercaseFirst
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 17, weight: .semibold)
//        if contact.idType == .username {
//            tf.leftView = UILabel.with(text: "@", textSize: 17, weight: .semibold)
//            tf.leftViewMode = .always
//        }
        tf.autocapitalizationType = .none
        return tf
    }()
    
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
        title = "links".localized().uppercaseFirst
    }
    
    override func bind() {
        super.bind()
        
        links.subscribe(onNext: { (links) in
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
        
        let testField = linkField(serviceName: "telegram", linkType: "username", textField: textField)
        
        stackView.addArrangedSubviews([testField, addLinkButton])
    }
    
    // MARK: - View builders
    private func linkField(serviceName: String, linkType: String, textField: UITextField) -> UIView {
        let vStack = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fillEqually)
        
        let titleView: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
            let icon = UIImageView(width: 20, height: 20, imageNamed: serviceName + "-icon")
            let label = UILabel.with(text: serviceName, textSize: 15, weight: .semibold)
            hStack.addArrangedSubviews([icon, label])
            
            return hStack
        }()
        
        let textFieldWrapper: UIStackView = {
            let vStack = UIStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
            let label = UILabel.with(text: linkType, textSize: 12, weight: .medium, textColor: .appGrayColor)
            vStack.addArrangedSubviews([label, textField])
            return vStack
        }()
        
        vStack.addArrangedSubviews([titleView, textFieldWrapper])
        
        let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
        view.addSubview(vStack)
        vStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 6, left: 16, bottom: 10, right: 16))
        
        let spacer = UIView(height: 2, backgroundColor: .appLightGrayColor)
        view.addSubview(spacer)
        spacer.autoAlignAxis(toSuperviewAxis: .horizontal)
        spacer.autoPinEdge(toSuperviewEdge: .leading)
        spacer.autoPinEdge(toSuperviewEdge: .trailing)
        return view
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
