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

class MyProfileEditLinksVC: MyProfileDetailFlowVC, LinkCellDelegate {
    // MARK: - Properties
    lazy var links = BehaviorRelay<ResponseAPIContentGetProfilePersonal>(value: ResponseAPIContentGetProfilePersonal())
    var linkCells: [LinkCell] {stackView.arrangedSubviews.compactMap {$0 as? LinkCell}}
    
    // MARK: - Subviews
    lazy var saveButton = UIBarButtonItem(title: "save".localized().uppercaseFirst, style: .done, target: self, action: #selector(saveButtonDidTouch))
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
        
        setLeftBarButton(imageName: "icon-back-bar-button-black-default", tintColor: .appBlackColor, action: #selector(askForSavingAndGoBack))
        
        saveButton.tintColor = .appBlackColor
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func profileDidUpdate(_ profile: ResponseAPIContentGetProfile?) {
        stackView.removeArrangedSubviews()
        var subviews = profile?.personal?.filledLinks.compactMap {self.addLinkField(contactType: $0.key, value: $0.value.value)} ?? []
        subviews.append(contentsOf: profile?.personal?.unfilledLinks.compactMap{self.addLinkField(contactType: $0, value: "")} ?? [])
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
        
        Observable<Void>.combineLatest(
            linkCells.map {$0.textField.rx.text.map {_ in ()}}
        )
            .map {_ in self.dataHasChanged()}
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.spacing = 20
    }
    
    // MARK: - Data handler
    func dataHasChanged() -> Bool {
        var flag = false
        for cell in linkCells {
            let textFieldText = cell.textField.text?.trimmed ?? ""
            
            if cell.isHidden {
                // for hidden cell, the old data is about to be deleted
                let oldValue = profile?.personal?.getContact(contactType: cell.contactType)?.value?.trimmed ?? ""
                if !oldValue.isEmpty {flag = true}
            } else {
                // for visible cell, compare new data with the old one
                let newValue = self.links.value.getContact(contactType: cell.contactType)?.value?.trimmed ?? ""
                if textFieldText != newValue {flag = true}
            }
            
            if flag == true {break}
        }
        return flag
    }
    
    override func reloadData() {
        super.reloadData()
        
        for (key, _) in links.value.filledLinks  {
            linkCells.first(where: {$0.contactType == key})?.isHidden = false
        }
        
        for link in links.value.unfilledLinks {
            linkCells.first(where: {$0.contactType == link})?.isHidden = true
        }
        
        addLinkButton.isHidden = links.value.unfilledLinks.isEmpty
    }
    
    // MARK: - View builders
    private func addLinkField(contactType: ResponseAPIContentGetProfilePersonal.LinkType, value: String?) -> LinkCell {
        let linkCell = LinkCell(contactType: contactType)
        linkCell.textField.changeTextNotify(value)
        linkCell.delegate = self
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
            var contact: ResponseAPIContentGetProfileContact?
            var string = ""
            if !cell.isHidden && cell.textField.text?.isEmpty == false {
                contact = ResponseAPIContentGetProfileContact(value: cell.textField.text, default: false)
                string = contact!.encodedString
            }
            params[cell.contactType.rawValue] = string
            switch cell.contactType {
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
    
    @objc func askForSavingAndGoBack() {
        if dataHasChanged() {
            showAlert(title: "save".localized().uppercaseFirst, message: "do you want to save the changes you've made?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.saveButtonDidTouch()
                    return
                }
                self.back()
            }
        } else {
            back()
        }
    }
    
    // MARK: - Helpers
    private func addLinkToService(_ contactType: ResponseAPIContentGetProfilePersonal.LinkType, value: String = "") {
        let value = ResponseAPIContentGetProfileContact(value: value, default: false)
        addContactType(contactType, value: value)
    }
    
    private func addContactType(_ contactType: ResponseAPIContentGetProfilePersonal.LinkType, value: ResponseAPIContentGetProfileContact?) {
        var links = self.links.value
        switch contactType {
        case .twitter:
            links.twitter = value
        case .facebook:
            links.facebook = value
        case .instagram:
            links.instagram = value
        case .linkedin:
            links.linkedin = value
        case .github:
            links.gitHub = value
        default:
            return
        }
        self.links.accept(links)
    }
    
    func linkCellOptionButtonDidTouch(_ linkCell: LinkCell) {
        showCommunActionSheet(
            title: linkCell.contactType.rawValue.uppercaseFirst,
            actions: [
//                CommunActionSheet.Action(title: "edit".localized().uppercaseFirst,
//                                         icon: UIImage(named: "edit"),
//                                         handle: {[unowned self] in
//                                            self.onUpdateBio()
//                }),
                CommunActionSheet.Action(title: "delete".localized().uppercaseFirst,
                                         icon: UIImage(named: "delete"),
                                         tintColor: .red,
                                         handle: {[unowned self] in
                                             self.addContactType(linkCell.contactType, value: nil)
                                            linkCell.textField.sendActions(for: .valueChanged)
                    }
                )
        ])
    }
}
