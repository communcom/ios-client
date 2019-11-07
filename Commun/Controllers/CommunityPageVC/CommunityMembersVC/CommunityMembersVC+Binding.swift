//
//  CommunityMembersVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension CommunityMembersVC: UICollectionViewDelegateFlowLayout {
    func bindSegmentedControl() {
        let segmentedItem = topTabBar.selectedIndex
            .map { index -> CommunityMembersViewModel.SegmentedItem in
                switch index {
                case 0:
                    return .all
                case 1:
                    return .leaders
                case 2:
                    return .friends
                default:
                    fatalError("not found selected index")
                }
            }.share()
        
        segmentedItem
            .bind(to: viewModel.segmentedItem)
            .disposed(by: disposeBag)
        
        segmentedItem
            .map {$0 == .all}
            .subscribe(onNext: { (isAll) in
                self.headerView.removeFromSuperview()
                if isAll {
                    self.showHeaderView()
                }
                else {
                    self.tableView.tableHeaderView = nil
                }
            })
            .disposed(by: disposeBag)
    }
    
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
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "SubscribersCell") as! SubscribersCell
                    cell.setUp(with: subscriber)
                    
                    if indexPath.row >= self.viewModel.subscribersVM.items.value.count - 5 {
                        self.viewModel.fetchNext()
                    }
                    
                    return cell
                case .leader(let leader):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityLeaderCell") as! CommunityLeaderCell
                    cell.setUp(with: leader)
                    
                    if indexPath.row >= self.viewModel.leadersVM.items.value.count - 5 {
                        self.viewModel.fetchNext()
                    }
                    return cell
                }
            }
        )
        
        
        
        viewModel.items
            .map { items in
                items.compactMap {item -> CustomElementType? in
                    if let item = item as? ResponseAPIContentGetLeader {
                        return .leader(item)
                    }
                    if let item = item as? ResponseAPIContentResolveProfile {
                        return .subscriber(item)
                    }
                    return nil
                }
            }
            .map {[AnimatableSectionModel<String, CustomElementType>(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let leaderDataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, ResponseAPIContentGetLeader>>(
            configureCell: { (dataSource, tableView, indexPath, leader) -> UICollectionViewCell in
                
                if indexPath.row >= self.viewModel.leadersVM.items.value.count - 2 {
                    self.viewModel.fetchNext()
                }
                
                let cell = self.headerView.leadersCollectionView.dequeueReusableCell(withReuseIdentifier: "LeaderCollectionCell", for: indexPath) as! LeaderCollectionCell
                cell.setUp(with: leader)
                return cell
            }
        )
        
        viewModel.leadersVM.items
            .skip(1)
            .map {[AnimatableSectionModel<String, ResponseAPIContentGetLeader>(model: "", items: $0)]}
            .bind(to: headerView.leadersCollectionView.rx.items(dataSource: leaderDataSource))
            .disposed(by: disposeBag)
        
        headerView.leadersCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // OnItemSelected
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath in
//                self?.cellSelected(indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    func showHeaderView() {
        let view = UIView(forAutoLayout: ())
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges()
        
        tableView.tableHeaderView = view
        
        view.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        view.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        
        tableView.tableFooterView = tableView.tableFooterView
        
        tableView.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 166)
    }
}
