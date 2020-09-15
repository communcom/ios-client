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
    let originalRules: [ResponseAPIContentGetCommunityRule]
    lazy var rules = BehaviorRelay<[ResponseAPIContentGetCommunityRule]>(value: originalRules)
    var dataSource: RxTableViewSectionedAnimatedDataSource<RuleListSectionModel>!
    
    // MARK: - Subviews
    lazy var tableView: UITableView = {
        let tableView = UITableView(backgroundColor: .clear)
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        tableView.separatorStyle = .none
        tableView.register(CommunityRuleEditableCell.self, forCellReuseIdentifier: "CommunityRuleEditableCell")
        return tableView
    }()
    
    // MARK: - Initializers
    init(rules: [ResponseAPIContentGetCommunityRule]) {
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
}
