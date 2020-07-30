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
        title = "links".localized().uppercaseFirst
    }
    
    override func profileDidUpdate(_ profile: ResponseAPIContentGetProfile?) {
        self.links.accept(profile?.personal?.contacts)
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
    
    // MARK: - Data handler
    override func reloadData() {
        super.reloadData()
        
        guard let links = self.links.value else {
            DispatchQueue.main.async {
                self.links.accept(ResponseAPIContentGetProfileContacts())
            }
            return
        }
        stackView.removeArrangedSubviews()
        
        for (key, value) in links.filledLinks {
            addLinkField(contact: key, value: value.value)
        }
        
        if !links.unfilledLinks.isEmpty {
            stackView.addArrangedSubview(addLinkButton)
        }
    }
    
    // MARK: - View builders
    private func addLinkField(contact: ResponseAPIContentGetProfileContacts.ContactType, value: String?) {
        let vStack = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fillEqually)
        
        let titleView: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
            let icon = UIImageView(width: 20, height: 20, imageNamed: contact.rawValue + "-icon")
            let label = UILabel.with(text: contact.rawValue.uppercaseFirst, textSize: 15, weight: .semibold)
            hStack.addArrangedSubviews([icon, label])
            
            return hStack
        }()
        
        let textField = ContactTextField(contact: contact)
        textField.text = value
        
        let textFieldWrapper: UIStackView = {
            let vStack = UIStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
            let label = UILabel.with(text: contact.identifiedBy.rawValue.localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .appGrayColor)
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
        guard let links = self.links.value else {return}
        let actions: [CommunActionSheet.Action] = links.unfilledLinks.map { contact in
            var imageNamed = contact.rawValue + "-icon"
            if contact == .instagram {imageNamed = "sign-up-with-instagram"}
            return CommunActionSheet.Action(
                title: contact.rawValue.uppercaseFirst,
                icon: UIImage(named: imageNamed),
                style: .default,
                marginTop: 0,
                defaultIconOnTheRight: false,
                handle: {
                    self.addLinkToService(contact)
                }
            )
        }
        
        showCommunActionSheet(title: "add contact".localized().uppercaseFirst, actions: actions)
    }
    
    // MARK: - Helpers
    private func addLinkToService(_ contact: ResponseAPIContentGetProfileContacts.ContactType) {
        var links = self.links.value ?? ResponseAPIContentGetProfileContacts()
        let emptyContact = ResponseAPIContentGetProfileContact(value: "", default: false)
        switch contact {
        case .twitter:
            links.twitter = emptyContact
        case .facebook:
            links.facebook = emptyContact
        case .instagram:
            links.instagram = emptyContact
        case .linkedin:
            links.linkedin = emptyContact
        case .github:
            links.gitHub = emptyContact
        default:
            return
        }
        self.links.accept(links)
    }
}
