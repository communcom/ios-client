//
//  CommunityMembersVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension CommunityMembersVC {
    func bindState() {
        viewModel.listLoadingState
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading(let isLoading):
                    if (isLoading) {
                        self?.tableView.addNotificationsLoadingFooterView()
                    }
                    else {
                        self?.tableView.tableFooterView = UIView()
                    }
                    break
                case .listEnded:
                    self?.tableView.tableFooterView = UIView()
                case .listEmpty:
                    guard let strongSelf = self else {return}
                    var title = "empty"
                    var description = "not found"
                    switch strongSelf.viewModel.segmentedItem.value {
                    case .all:
                        title = "no members"
                        description = "members not found"
                    case .leaders:
                        title = "no leaders"
                        description = "leaders not found"
                    case .friends:
                        title = "no friends"
                        description = "friends not found"
                    }
                    
                    strongSelf.tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
                case .error(_):
                    guard let strongSelf = self else {return}
                    #warning("error handling")
//                    strongSelf.tableView.addListErrorFooterView(with: #selector(strongSelf.didTapTryAgain(gesture:)), on: strongSelf)
//                    strongSelf.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindList() {
        // bind items
        let dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, CustomElementType>>(
            configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
                switch element {
                case .subscriber(let subscriber):
                    
                case .leader(let leader):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityLeaderCell") as! CommunityLeaderCell
                    cell.setUp(with: leader)
                    return cell
                case .about(let string):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityAboutCell") as! CommunityAboutCell
                    cell.label.text = string
                    return cell
                case .rule(let rule):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityRuleCell") as! CommunityRuleCell
                    cell.rowIndex = indexPath.row
                    cell.setUp(with: rule)
                    return cell
                }
                return UITableViewCell()
            }
        )
        
        viewModel.items
            .map { items in
                items.compactMap {item -> CustomElementType? in
                    if let item = item as? ResponseAPIContentGetPost {
                        return .post(item)
                    }
                    if let item = item as? ResponseAPIContentGetLeader {
                        return .leader(item)
                    }
                    if let item = item as? String {
                        return .about(item)
                    }
                    if let item = item as? ResponseAPIContentGetCommunityRule {
                        return .rule(item)
                    }
                    return nil
                }
            }
            .map {[AnimatableSectionModel<String, CustomElementType>(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // OnItemSelected
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath in
//                self?.cellSelected(indexPath)
            })
            .disposed(by: disposeBag)
    }
}
