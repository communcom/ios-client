//
//  MyProfileEditLinksVC.swift
//  Commun
//
//  Created by Chung Tran on 7/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MyProfileEditLinksVC: MyProfileDetailFlowVC {
    // MARK: - Properties
    lazy var links = BehaviorRelay<ResponseAPIContentGetProfileContacts>(value: ResponseAPIContentGetProfileContacts())
    var linkCells: [LinkCell] {stackView.arrangedSubviews.compactMap {$0 as? LinkCell}}
    
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
    
    override func setUpArrangedSubviews() {
        var subviews = links.value.filledLinks.compactMap {self.addLinkField(contact: $0.key, value: $0.value.value)}
        subviews.append(contentsOf: links.value.unfilledLinks.compactMap{self.addLinkField(contact: $0, value: "")})
        subviews.forEach {$0.isHidden = true}
        stackView.addArrangedSubviews(subviews)
        stackView.addArrangedSubview(addLinkButton)
    }
    
    override func profileDidUpdate(_ profile: ResponseAPIContentGetProfile?) {
        self.links.accept(profile?.personal?.contacts ?? ResponseAPIContentGetProfileContacts())
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
        
        for (key, _) in links.value.filledLinks  {
            linkCells.first(where: {$0.contact == key})?.isHidden = false
        }
        
        for link in links.value.unfilledLinks {
            linkCells.first(where: {$0.contact == link})?.isHidden = true
        }
        
        addLinkButton.isHidden = links.value.unfilledLinks.isEmpty
    }
    
    // MARK: - View builders
    private func addLinkField(contact: ResponseAPIContentGetProfileContacts.ContactType, value: String?) -> LinkCell {
        let linkCell = LinkCell(contact: contact)
        stackView.addArrangedSubview(linkCell)
        return linkCell
    }
    
    // MARK: - Actions
    @objc func addLinkButtonDidTouch() {
        let actions: [CommunActionSheet.Action] = links.value.unfilledLinks.map { contact in
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
    private func addLinkToService(_ contact: ResponseAPIContentGetProfileContacts.ContactType, value: String = "") {
        var links = self.links.value
        let emptyContact = ResponseAPIContentGetProfileContact(value: value, default: false)
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
