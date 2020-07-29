//
//  MyProfileEditLinksVC.swift
//  Commun
//
//  Created by Chung Tran on 7/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class MyProfileEditLinksVC: MyProfileDetailFlowVC {
    // MARK: - Nested types
    class TextField: UITextField {
        enum IdType: String {
            case username
            case link
        }
        
        var idType: IdType = .link {
            didSet {
                switch idType {
                case .username:
                    leftView = UILabel.with(text: "@", textSize: 17, weight: .semibold)
                    leftViewMode = .always
                case .link:
                    leftView = nil
                    leftViewMode = .never
                }
            }
        }
        var serviceName: String?
    }
    
    // MARK: - Properties
    lazy var links = BehaviorRelay<ResponseAPIContentGetProfileContacts?>(value: nil)
    
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
        super.setUp()
        self.links.accept(profile?.personal?.contacts)
        title = "links".localized().uppercaseFirst
    }
    
    override func bind() {
        super.bind()
        
        links
            .subscribe(onNext: { (_) in
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
        
        if let value = links.value?.twitter {
            addLinkField(serviceName: "twitter", value: value)
        }
        
        if let value = links.value?.facebook {
            addLinkField(serviceName: "facebook", value: value)
        }
        
        if let value = links.value?.youtube {
            addLinkField(serviceName: "youtube", value: value)
        }
        
        if let value = links.value?.instagram {
            addLinkField(serviceName: "instagram", value: value)
        }
        
        if let value = links.value?.linkedIn {
            addLinkField(serviceName: "linkedin", value: value)
        }
        
        if let value = links.value?.github {
            addLinkField(serviceName: "github", value: value)
        }
        
        stackView.addArrangedSubview(addLinkButton)
    }
    
    // MARK: - View builders
    private func addLinkField(serviceName: String, value: String?) {
        let vStack = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fillEqually)
        
        let titleView: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
            let icon = UIImageView(width: 20, height: 20, imageNamed: serviceName + "-icon")
            let label = UILabel.with(text: serviceName.uppercaseFirst, textSize: 15, weight: .semibold)
            hStack.addArrangedSubviews([icon, label])
            
            return hStack
        }()
        
        let textField = TextField()
        textField.serviceName = serviceName
        switch serviceName {
        case "youtube":
            textField.idType = .link
        default:
            textField.idType = .username
        }
        textField.placeholder = ("your " + textField.idType.rawValue).localized().uppercaseFirst
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 17, weight: .semibold)
        textField.autocapitalizationType = .none
        textField.text = value
        
        let textFieldWrapper: UIStackView = {
            let vStack = UIStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
            var linkType = textField.idType.rawValue
            if serviceName == "youtube" {
                linkType = "channel link".localized().uppercaseFirst
            }
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
        
        stackView.addArrangedSubview(view)
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
                    self.addLinkToService("instagram")
                }
            ),
            CommunActionSheet.Action(
                title: "Linkedin".localized().uppercaseFirst,
                icon: UIImage(named: "linkedin-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    self.addLinkToService("linkedin")
                }
            ),
            CommunActionSheet.Action(
                title: "Github",
                icon: UIImage(named: "github-icon"),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    self.addLinkToService("github")
                }
            ),
//            CommunActionSheet.Action(
//                title: "Dribbble",
//                icon: UIImage(named: "dribble-icon"),
//                style: .default,
//                marginTop: 0,
//                defaultIconOnTheRight: false,
//                handle: {
//
//                }
//            )
        ])
    }
    
    // MARK: - Helpers
    private func addLinkToService(_ serviceName: String) {
        var links = self.links.value ?? ResponseAPIContentGetProfileContacts()
        switch serviceName {
        case "instagram":
            links.instagram = ""
        case "linkedin":
            links.linkedIn = ""
        case "github":
            links.github = ""
        default:
            return
        }
        self.links.accept(links)
    }
}
