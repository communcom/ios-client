//
//  MyProfileEditContactsVC.swift
//  Commun
//
//  Created by Chung Tran on 7/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MyProfileEditContactsVC: MyProfileDetailFlowVC, GeneralLinkCellDelegate {
    // MARK: - Properties
    var originalContacts: ResponseAPIContentGetProfilePersonalMessengers {profile?.personal?.messengers ?? ResponseAPIContentGetProfilePersonalMessengers()}
    lazy var draftContacts = BehaviorRelay<ResponseAPIContentGetProfilePersonalMessengers>(value: ResponseAPIContentGetProfilePersonalMessengers())
    var messengerCells: [MessengerCell] {stackView.arrangedSubviews.compactMap {$0 as? MessengerCell}}
    
    // MARK: - Subviews
    lazy var saveButton = UIBarButtonItem(title: "save".localized().uppercaseFirst, style: .done, target: self, action: #selector(saveButtonDidTouch))
    lazy var addContactButton: UIView = {
        let view = UIView(height: 57, backgroundColor: .appWhiteColor, cornerRadius: 10)
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
        
        setLeftBarButton(imageName: "icon-back-bar-button-black-default", tintColor: .appBlackColor, action: #selector(askForSavingAndGoBack))
        
        saveButton.tintColor = .appBlackColor
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func profileDidUpdate() {
        stackView.removeArrangedSubviews()
        var subviews = originalContacts.filledContacts.compactMap {self.addContactField($0.key, value: $0.value.value, isDefault: $0.value.default ?? false)}
        subviews.append(contentsOf: originalContacts.unfilledContacts.compactMap{self.addContactField($0, value: "", isDefault: true)})
        subviews.forEach {
            $0.isHidden = true
        }
        stackView.addArrangedSubviews(subviews)
        stackView.addArrangedSubview(addContactButton)
        draftContacts.accept(originalContacts)
    }
    
    override func bind() {
        super.bind()
        
        draftContacts
            .subscribe(onNext: { (_) in
                self.reloadData()
            })
            .disposed(by: disposeBag)
        
        var observables = messengerCells.map {$0.textField.rx.text.map {_ in ()}}
            observables.append(contentsOf: messengerCells.map {$0.switcher.rx.isOn.map {_ in ()}})
        Observable<Void>.combineLatest(observables)
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
        for cell in messengerCells {
            let textFieldText = cell.textField.text?.trimmed ?? ""
            
            if cell.isHidden {
                // for hidden cell, the old data is about to be deleted
                let oldValue = originalContacts.getContact(messengerType: cell.messengerType)?.value?.trimmed ?? ""
                if !oldValue.isEmpty {flag = true}
            } else {
                // for visible cell, compare new data with the old one
                let contact = draftContacts.value.getContact(messengerType: cell.messengerType)
                let newValue = contact?.value?.trimmed ?? ""
                if textFieldText != newValue {flag = true}
                if cell.switcher.isOn != (contact?.default ?? false) {flag = true}
            }
            
            if flag == true {break}
        }
        return flag
    }
    
    override func reloadData() {
        super.reloadData()
        for (key, _) in draftContacts.value.filledContacts  {
            messengerCells.first(where: {$0.messengerType == key})?.isHidden = false
        }
        
        for link in draftContacts.value.unfilledContacts {
            messengerCells.first(where: {$0.messengerType == link})?.isHidden = true
        }
        
        addContactButton.isHidden = draftContacts.value.unfilledContacts.isEmpty
    }
    
    // MARK: - View builders
    private func addContactField(_ messengerType: ResponseAPIContentGetProfilePersonalMessengers.MessengerType, value: String?, isDefault: Bool) -> MessengerCell {
        let linkCell = MessengerCell(messengerType: messengerType)
        linkCell.switcher.isOn = isDefault
        linkCell.textField.changeTextNotify(value)
        linkCell.delegate = self
        return linkCell
    }
    
    // MARK: - Actions
    @objc func addContactButtonDidTouch() {
        let actions: [CMActionSheet.Action] = draftContacts.value.unfilledContacts.map { link in
            return .customLayout(
                height: 50,
                title: link.rawValue.uppercaseFirst,
                textSize: 15,
                spacing: 10,
                iconName: link.rawValue.lowercased() + "-icon",
                iconSize: 24,
                showIconFirst: true) {
                    self.addContactToService(link)
            }
        }
        
        showCMActionSheet(title: "add link".localized().uppercaseFirst, actions: actions)
    }
    
    @objc func saveButtonDidTouch() {
        view.endEditing(true)
        var params = [String: String]()
        
        var profile = ResponseAPIContentGetProfile.current
        var messengers = profile?.personal?.messengers ?? ResponseAPIContentGetProfilePersonalMessengers()
        messengerCells.forEach { cell in
            var link: ResponseAPIContentGetProfilePersonalLink?
            var string = ""
            if !cell.isHidden && cell.textField.text?.isEmpty == false {
                link = ResponseAPIContentGetProfilePersonalLink(value: cell.textField.text, defaultValue: cell.switcher.isOn)
                string = link!.encodedString
            }
            params[cell.messengerType.rawValue] = string
            switch cell.messengerType {
            case .weChat:
                messengers.weChat = link
            case .telegram:
                messengers.telegram = link
            case .whatsApp:
                messengers.whatsApp = link
            }
        }
        
        if params.isEmpty {
            showErrorWithMessage("nothing to save".localized().uppercaseFirst)
            return
        }
        
        showIndetermineHudWithMessage("saving".localized().uppercaseFirst + "...")
        BlockchainManager.instance.updateProfile(params: params, waitForTransaction: false)
            .subscribe(onCompleted: {
                profile?.personal?.messengers = messengers
                ResponseAPIContentGetProfile.current = profile
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
    private func addContactToService(_ messengerType: ResponseAPIContentGetProfilePersonalMessengers.MessengerType, value: String = "") {
        let value = ResponseAPIContentGetProfilePersonalLink(value: value, defaultValue: true)
        addContactType(messengerType, value: value)
    }
    
    private func addContactType(_ messengerType: ResponseAPIContentGetProfilePersonalMessengers.MessengerType, value: ResponseAPIContentGetProfilePersonalLink?) {
        var links = draftContacts.value
        switch messengerType {
        case .weChat:
            links.weChat = value
        case .telegram:
            links.telegram = value
        case .whatsApp:
            links.whatsApp = value
        }
        draftContacts.accept(links)
    }
    
    func linkCellOptionButtonDidTouch<T: UITextField>(_ linkCell: GeneralLinkCell<T>) {
        let linkCell = linkCell as! MessengerCell
        showCMActionSheet(
            title: linkCell.messengerType.rawValue.uppercaseFirst,
            actions: [
                .default(
                    title: "delete".localized().uppercaseFirst,
                    iconName: "delete",
                    tintColor: .appRedColor,
                    handle: {[unowned self] in
                        self.addContactType(linkCell.messengerType, value: nil)
                        linkCell.textField.sendActions(for: .valueChanged)
                    }
                )
        ])
    }
}
