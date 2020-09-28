//
//  CMRulesVC.swift
//  Commun
//
//  Created by Chung Tran on 9/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMRulesVC: CMTableViewController<ResponseAPIContentGetCommunityRule, CommunityRuleEditableCell> {
    override init(originalItems: [ResponseAPIContentGetCommunityRule] = []) {
        let originalItems = originalItems.compactMap {rule -> ResponseAPIContentGetCommunityRule in
            var rule = rule
            rule.isExpanded = false
            return rule
        }
        super.init(originalItems: originalItems)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
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
            self.add(rule)
        }
        show(vc, sender: nil)
    }
    
    func add(_ rule: ResponseAPIContentGetCommunityRule) {
        
    }
    
    func remove(_ ruleId: String) {
        
    }
    
    func update(_ rule: ResponseAPIContentGetCommunityRule) {
        
    }
}

extension CMRulesVC: CommunityRuleEditableCellDelegate {
    func communityRuleEditableCellButtonRemoveDidTouch(_ cell: CommunityRuleEditableCell) {
        guard let row = tableView.indexPath(for: cell)?.row,
            let id = itemsRelay.value[safe: row]?.id
        else {
            return
        }
        remove(id)
    }
    
    func communityRuleEditableCellButtonEditDidTouch(_ cell: CommunityRuleEditableCell) {
        guard let row = tableView.indexPath(for: cell)?.row,
            let rule = itemsRelay.value[safe: row]
        else {
            return
        }
        
        let vc = EditRuleVC(rule: rule)
        vc.updateRuleHandler = {rule in
            self.update(rule)
        }
        show(vc, sender: nil)
    }
}
