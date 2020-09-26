//
//  RulesVC.swift
//  Commun
//
//  Created by Chung Tran on 9/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class RulesVC: CMTableViewController<ResponseAPIContentGetCommunityRule, CommunityRuleEditableCell> {
    
    // MARK: - Properties
    let communityCode: String
    let communityIssuer: String
    
    // MARK: - Initializers
    init(communityCode: String, communityIssuer: String, rules: [ResponseAPIContentGetCommunityRule]) {
        self.communityCode = communityCode
        self.communityIssuer = communityIssuer
        let originalItems = rules.compactMap {rule -> ResponseAPIContentGetCommunityRule in
            var rule = rule
            rule.isExpanded = false
            return rule
        }
        super.init(originalItems: originalItems)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "rules".localized().uppercaseFirst
        
        // footerView
        let footerView: UIView = {
            let view = UIView(height: 57, backgroundColor: .appWhiteColor, cornerRadius: 10)
            let label = UILabel.with(text: "+ " + "add new rule".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor)
            view.addSubview(label)
            label.autoCenterInSuperview()
            
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addRuleButtonDidTouch)))
            return view
        }()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 67))
        view.addSubview(footerView)
        footerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
        tableView.tableFooterView = view
    }
    
    override func bind() {
        super.bind()
        
        // Rule changed (ex: isExpanded)
        ResponseAPIContentGetCommunityRule
            .observeItemChanged()
            .subscribe(onNext: { rule in
                var rules = self.itemsRelay.value
                if let index = rules.firstIndex(where: {$0.identity == rule.identity})
                {
//                    if rule.isExpanded != rules[index].isExpanded {
//                        self.ruleRowHeights.removeValue(forKey: rule.identity)
//                    }
                    rules[index] = rule
                    self.itemsRelay.accept(rules)
                }
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunityRule
            .observeItemDeleted()
            .subscribe(onNext: { (rule) in
                var rules = self.itemsRelay.value
                rules.removeAll(where: {$0.identity == rule.identity})
                self.itemsRelay.accept(rules)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func configureCell(item: ResponseAPIContentGetCommunityRule, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(item: item, indexPath: indexPath) as! CommunityRuleEditableCell
        cell.rowIndex = indexPath.row
        cell.setUp(with: item)
        cell.delegate = self
        return cell
    }
    
    // MARK: - Actions
    @objc func addRuleButtonDidTouch() {
        let vc = EditRuleVC()
        vc.newRuleHandler = {rule in
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
        show(vc, sender: nil)
    }
}

extension RulesVC: CommunityRuleEditableCellDelegate {
    func communityRuleEditableCellButtonRemoveDidTouch(_ cell: CommunityRuleEditableCell) {
        guard let row = tableView.indexPath(for: cell)?.row,
            let id = itemsRelay.value[safe: row]?.id
        else {
            return
        }
        
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
    
    func communityRuleEditableCellButtonEditDidTouch(_ cell: CommunityRuleEditableCell) {
        guard let row = tableView.indexPath(for: cell)?.row,
            let rule = itemsRelay.value[safe: row]
        else {
            return
        }
        
        let vc = EditRuleVC(rule: rule)
        vc.updateRuleHandler = {rule in
            self.showIndetermineHudWithMessage("creating proposal".localized().uppercaseFirst)
            let updateRequest = RequestAPIRule.update(rule: rule).convertToJSON()
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
        show(vc, sender: nil)
    }
}
