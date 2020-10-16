//
//  RulesVC.swift
//  Commun
//
//  Created by Chung Tran on 9/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class RulesVC: CMRulesVC {
    
    // MARK: - Properties
    let communityCode: String
    let communityIssuer: String
    
    // MARK: - Initializers
    init(communityCode: String, communityIssuer: String, rules: [ResponseAPIContentGetCommunityRule]) {
        self.communityCode = communityCode
        self.communityIssuer = communityIssuer
        super.init(originalItems: rules)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "rules".localized().uppercaseFirst
    }
    
    // MARK: - Actions
    override func add(_ rule: ResponseAPIContentGetCommunityRule) {
//        super.add(rule)
        self.showIndetermineHudWithMessage("creating proposal".localized().uppercaseFirst)
        let addRequest = RequestAPIRule.add(title: rule.title ?? "", text: rule.text).convertToJSON()
        BlockchainManager.instance.editCommunnity(
            communityCode: self.communityCode,
            commnityIssuer: self.communityIssuer,
            rules: addRequest
        )
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(title: "proposal created".localized().uppercaseFirst, message: "proposal for rule adding has been created".localized().uppercaseFirst)
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    override func remove(_ rule: ResponseAPIContentGetCommunityRule) {
//        super.remove(ruleId)
        guard let id = rule.id else {return}
        showAlert(title: "remove rule".localized().uppercaseFirst, message: "do you really want to remove this rule?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1, completion: { (index) in
            if index == 0 {
                self.showIndetermineHudWithMessage("creating proposal".localized().uppercaseFirst)
                let removeRequest = RequestAPIRule.remove(id: id).convertToJSON()
                BlockchainManager.instance.editCommunnity(
                    communityCode: self.communityCode,
                    commnityIssuer: self.communityIssuer,
                    rules: removeRequest
                )
                    .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
                    .subscribe(onCompleted: {
                        self.hideHud()
                        self.showAlert(title: "proposal created".localized().uppercaseFirst, message: "proposal for rule removing has been created".localized().uppercaseFirst)
                    }) { (error) in
                        self.hideHud()
                        self.showError(error)
                    }
                    .disposed(by: self.disposeBag)
                    
            }
        })
    }
    
    override func update(_ item: ResponseAPIContentGetCommunityRule, with newItem: ResponseAPIContentGetCommunityRule) {
//        super.update(rule)
        self.showIndetermineHudWithMessage("creating proposal".localized().uppercaseFirst)
        let updateRequest = RequestAPIRule.update(rule: newItem).convertToJSON()
        BlockchainManager.instance.editCommunnity(
            communityCode: self.communityCode,
            commnityIssuer: self.communityIssuer,
            rules: updateRequest
        )
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(title: "proposal created".localized().uppercaseFirst, message: "proposal for rule updating has been created".localized().uppercaseFirst)
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
}
