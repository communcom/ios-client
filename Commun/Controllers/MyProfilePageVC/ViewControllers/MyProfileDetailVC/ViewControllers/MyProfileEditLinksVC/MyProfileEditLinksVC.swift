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
    var originalLinks: ResponseAPIContentGetProfilePersonalLinks {profile?.personal?.links ?? ResponseAPIContentGetProfilePersonalLinks()}
    lazy var draftLinks = BehaviorRelay<ResponseAPIContentGetProfilePersonalLinks>(value: ResponseAPIContentGetProfilePersonalLinks())
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
    
    override func profileDidUpdate() {
        stackView.removeArrangedSubviews()
        var subviews = originalLinks.filledLinks.compactMap {self.addLinkField($0.key, value: $0.value.value)}
        subviews.append(contentsOf: originalLinks.unfilledLinks.compactMap{self.addLinkField($0, value: "")})
        subviews.forEach {
            $0.isHidden = true
        }
        stackView.addArrangedSubviews(subviews)
        stackView.addArrangedSubview(addLinkButton)
        self.draftLinks.accept(originalLinks)
    }
    
    override func bind() {
        super.bind()
        
        draftLinks
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
                let oldValue = originalLinks.getLink(linkType: cell.linkType)?.value?.trimmed ?? ""
                if !oldValue.isEmpty {flag = true}
            } else {
                // for visible cell, compare new data with the old one
                let newValue = self.draftLinks.value.getLink(linkType: cell.linkType)?.value?.trimmed ?? ""
                if textFieldText != newValue {flag = true}
            }
            
            if flag == true {break}
        }
        return flag
    }
    
    override func reloadData() {
        super.reloadData()
        
        for (key, _) in draftLinks.value.filledLinks  {
            linkCells.first(where: {$0.linkType == key})?.isHidden = false
        }
        
        for link in draftLinks.value.unfilledLinks {
            linkCells.first(where: {$0.linkType == link})?.isHidden = true
        }
        
        addLinkButton.isHidden = draftLinks.value.unfilledLinks.isEmpty
    }
    
    // MARK: - View builders
    private func addLinkField(_ linkType: ResponseAPIContentGetProfilePersonalLinks.LinkType, value: String?) -> LinkCell {
        let linkCell = LinkCell(linkType: linkType)
        linkCell.textField.changeTextNotify(value)
        linkCell.delegate = self
        return linkCell
    }
    
    // MARK: - Actions
    @objc func addLinkButtonDidTouch() {
        let actions: [CMActionSheet.Action] = draftLinks.value.unfilledLinks.map { link in
            var imageNamed = link.rawValue.lowercased() + "-icon"
            if link == .instagram {imageNamed = "sign-up-with-instagram"}
            
            return .customLayout(
                height: 50,
                title: link.rawValue.uppercaseFirst,
                textSize: 15,
                spacing: 10,
                iconName: imageNamed,
                iconSize: 24,
                showIconFirst: true) {
                    self.addLinkToService(link)
            }
        }
        
        showCMActionSheet(title: "add link".localized().uppercaseFirst, actions: actions)
    }
    
    @objc func saveButtonDidTouch() {
        view.endEditing(true)
        var params = [String: String]()
        
        var profile = ResponseAPIContentGetProfile.current
        var links = profile?.personal?.links ?? ResponseAPIContentGetProfilePersonalLinks()
        linkCells.forEach { cell in
            var link: ResponseAPIContentGetProfilePersonalLink?
            var string = ""
            if !cell.isHidden && cell.textField.text?.isEmpty == false {
                link = ResponseAPIContentGetProfilePersonalLink(value: cell.textField.text, defaultValue: false)
                string = link!.encodedString
            }
            params[cell.linkType.rawValue] = string
            switch cell.linkType {
            case .twitter:
                links.twitter = link
            case .facebook:
                links.facebook = link
            case .instagram:
                links.instagram = link
            case .linkedin:
                links.linkedin = link
            case .gitHub:
                links.gitHub = link
            }
        }
        
        if params.isEmpty {
            showErrorWithMessage("nothing to save".localized().uppercaseFirst)
            return
        }
        
        showIndetermineHudWithMessage("saving".localized().uppercaseFirst + "...")
        BlockchainManager.instance.updateProfile(params: params, waitForTransaction: false)
            .subscribe(onCompleted: {
                profile?.personal?.links = links
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
    private func addLinkToService(_ linkType: ResponseAPIContentGetProfilePersonalLinks.LinkType, value: String = "") {
        let value = ResponseAPIContentGetProfilePersonalLink(value: value, defaultValue: false)
        addLinkType(linkType, value: value)
    }
    
    private func addLinkType(_ linkType: ResponseAPIContentGetProfilePersonalLinks.LinkType, value: ResponseAPIContentGetProfilePersonalLink?) {
        var links = self.draftLinks.value
        switch linkType {
        case .twitter:
            links.twitter = value
        case .facebook:
            links.facebook = value
        case .instagram:
            links.instagram = value
        case .linkedin:
            links.linkedin = value
        case .gitHub:
            links.gitHub = value
        }
        self.draftLinks.accept(links)
    }
    
    func linkCellOptionButtonDidTouch(_ linkCell: LinkCell) {
        showCMActionSheet(
            title: linkCell.linkType.rawValue.uppercaseFirst,
            actions: [
                .default(
                    title: "delete".localized().uppercaseFirst,
                    iconName: "delete",
                    tintColor: .appRedColor,
                    handle: {[unowned self] in
                        self.addLinkType(linkCell.linkType, value: nil)
                        linkCell.textField.sendActions(for: .valueChanged)
                    }
                )
        ])
    }
}
