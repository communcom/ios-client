//
//  RulesVC.swift
//  Commun
//
//  Created by Chung Tran on 9/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources

class RulesVC: BaseViewController {
    typealias RuleListSectionModel = AnimatableSectionModel<String, ResponseAPIContentGetCommunityRule>
    
    // MARK: - Properties
    let communityCode: String
    let communityIssuer: String
    let originalRules: [ResponseAPIContentGetCommunityRule]
    lazy var rules = BehaviorRelay<[ResponseAPIContentGetCommunityRule]>(value: originalRules)
    var dataSource: RxTableViewSectionedAnimatedDataSource<RuleListSectionModel>!
    
    // MARK: - Subviews
    lazy var tableView: UITableView = {
        let tableView = UITableView(backgroundColor: .clear)
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        tableView.separatorStyle = .none
        tableView.register(CommunityRuleEditableCell.self, forCellReuseIdentifier: "CommunityRuleEditableCell")
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
        return tableView
    }()
    
    // MARK: - Initializers
    init(communityCode: String, communityIssuer: String, rules: [ResponseAPIContentGetCommunityRule]) {
        self.communityCode = communityCode
        self.communityIssuer = communityIssuer
        originalRules = rules.compactMap {rule in
            var rule = rule
            rule.isExpanded = false
            return rule
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "rules".localized().uppercaseFirst
        view.backgroundColor = .appLightGrayColor
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
    }
    
    override func bind() {
        super.bind()
        dataSource = RxTableViewSectionedAnimatedDataSource<RuleListSectionModel>(
            configureCell: { (_, table, indexPath, rule) in
                let cell = table.dequeueReusableCell(withIdentifier: "CommunityRuleEditableCell") as! CommunityRuleEditableCell
                cell.rowIndex = indexPath.row
                cell.setUp(with: rule)
                cell.delegate = self
                return cell
            }
        )
        
        rules.asDriver()
            .map {[RuleListSectionModel(model: "", items: $0)]}
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // Rule changed (ex: isExpanded)
        ResponseAPIContentGetCommunityRule
            .observeItemChanged()
            .subscribe(onNext: { rule in
                var rules = self.rules.value
                if let index = rules.firstIndex(where: {$0.identity == rule.identity})
                {
//                    if rule.isExpanded != rules[index].isExpanded {
//                        self.ruleRowHeights.removeValue(forKey: rule.identity)
//                    }
                    rules[index] = rule
                    self.rules.accept(rules)
                }
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunityRule
            .observeItemDeleted()
            .subscribe(onNext: { (rule) in
                var rules = self.rules.value
                rules.removeAll(where: {$0.identity == rule.identity})
                self.rules.accept(rules)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
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
            let id = rules.value[safe: row]?.id
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
            let rule = rules.value[safe: row]
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
