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
    lazy var links = BehaviorRelay<ResponseAPIContentGetProfilePersonal>(value: ResponseAPIContentGetProfilePersonal())
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
        let save = UIBarButtonItem(title: "save".localized().uppercaseFirst, style: .done, target: self, action: #selector(saveButtonDidTouch))
        save.tintColor = .appBlackColor
        navigationItem.rightBarButtonItem = save
    }
    
    override func profileDidUpdate(_ profile: ResponseAPIContentGetProfile?) {
        stackView.removeArrangedSubviews()
        var subviews = links.value.filledLinks.compactMap {self.addLinkField(contact: $0.key, value: $0.value.value)}
        subviews.append(contentsOf: links.value.unfilledLinks.compactMap{self.addLinkField(contact: $0, value: "")})
        subviews.forEach {
            $0.isHidden = true
        }
        stackView.addArrangedSubviews(subviews)
        stackView.addArrangedSubview(addLinkButton)
        self.links.accept(profile?.personal ?? ResponseAPIContentGetProfilePersonal())
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
    private func addLinkField(contact: ResponseAPIContentGetProfilePersonal.LinkType, value: String?) -> LinkCell {
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
        
        showCommunActionSheet(title: "add link".localized().uppercaseFirst, actions: actions)
    }
    
    @objc func saveButtonDidTouch() {
        view.endEditing(true)
        var params = [String: String]()
        
        var profile = ResponseAPIContentGetProfile.current
        var personal = profile?.personal ?? ResponseAPIContentGetProfilePersonal()
        linkCells.forEach { cell in
            cell.textField.verify()
            if cell.textField.isValid {
                let contact = ResponseAPIContentGetProfileContact(value: cell.textField.text, default: false)
                let string = String(data: try! JSONEncoder().encode(contact), encoding: .utf8)
                params[cell.contact.rawValue] = string
                
                switch cell.contact {
                case .twitter:
                    personal.twitter = contact
                case .facebook:
                    personal.facebook = contact
                case .instagram:
                    personal.instagram = contact
                case .linkedin:
                    personal.linkedin = contact
                case .github:
                    personal.gitHub = contact
                default:
                    return
                }
            }
        }
        
        if params.isEmpty {
            showErrorWithMessage("nothing to save".localized().uppercaseFirst)
            return
        }
        
        showIndetermineHudWithMessage("saving".localized().uppercaseFirst + "...")
        BlockchainManager.instance.updateProfile(params: params, waitForTransaction: false)
            .subscribe(onCompleted: {
                profile?.personal = personal
                UserDefaults.standard.set(object: profile, forKey: Config.currentUserGetProfileKey)
                self.hideHud()
                self.showDone("saved".localized().uppercaseFirst)
                self.back()
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    private func addLinkToService(_ contact: ResponseAPIContentGetProfilePersonal.LinkType, value: String = "") {
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
