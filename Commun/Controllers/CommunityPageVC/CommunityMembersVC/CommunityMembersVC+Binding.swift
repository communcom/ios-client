//
//  CommunityMembersVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources
import Action

extension CommunityMembersVC: UICollectionViewDelegateFlowLayout {
    func bindSegmentedControl() {
        topTabBar.selectedIndex
            .map { index -> CommunityMembersViewModel.SegmentedItem in
                switch index {
                case 0:
                    return .all
                case 1:
                    return .leaders
                case 2:
                    return .friends
                case 3:
                    return .banned
                default:
                    fatalError("not found selected index")
                }
            }
            .bind(to: viewModel.segmentedItem)
            .disposed(by: disposeBag)
        
        viewModel.segmentedItem
            .map {$0 == .all}
            .subscribe(onNext: { (isAll) in
                self.headerView.removeFromSuperview()
                if isAll {
                    self.showHeaderView()
                } else {
                    self.tableView.tableHeaderView = nil
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindScrollView() {
        tableView.addLoadMoreAction { [weak self] in
            self?.viewModel.fetchNext()
        }
            .disposed(by: disposeBag)
    }
    
    func bindState() {
        viewModel.listLoadingState
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        self?.handleListLoading()
                    }
                case .listEnded:
                    self?.handleListEnded()
                case .listEmpty:
                    self?.handleListEmpty()
                case .error:
                    self?.handleListError()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindList() {
        // bind items
        let dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, CustomElementType>>(
            configureCell: { (_, tableView, indexPath, element) -> UITableViewCell in
                switch element {
                case .subscriber(let subscriber):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityMemberCell") as! CommunityMemberCell
                    cell.setUp(with: subscriber)
                    if self.viewModel.community.isLeader == true && Config.currentUser?.id != subscriber.userId {
                        cell.optionButton.rx.action = CocoaAction {
                            self.manageUser(subscriber)
                            return .just(())
                        }
                        cell.optionButton.isHidden = false
                    } else {
                        cell.optionButton.rx.action = nil
                        cell.optionButton.isHidden = true
                    }
                    
                    cell.delegate = self
                    
                    cell.roundedCorner = []
                    
                    if indexPath.row == 0 {
                        cell.roundedCorner.insert([.topLeft, .topRight])
                    }
                    
                    if indexPath.row == self.viewModel.items.value.count - 1 {
                        cell.roundedCorner.insert([.bottomLeft, .bottomRight])
                    }
                    
                    return cell
                case .leader(let leader):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityLeaderFollowCell") as! CommunityLeaderFollowCell
                    cell.setUp(with: leader)
                    cell.delegate = self
                    
                    cell.roundedCorner = []
                    
                    if indexPath.row == 0 {
                        cell.roundedCorner.insert([.topLeft, .topRight])
                    }
                    
                    if indexPath.row == self.viewModel.items.value.count - 1 {
                        cell.roundedCorner.insert([.bottomLeft, .bottomRight])
                    }
                    
                    return cell
                    
                case .bannedUser(let user):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityBannedUserCell") as! CommunityBannedUserCell
                    cell.setUp(with: user)
                    let unBanAction = CocoaAction {
                        if user.isUnBanProposalCreated == true {
                            self.showAlert(title: "proposal created".localized().uppercaseFirst, message: "you've already created proposal for unbanning this user".localized().uppercaseFirst)
                            return .just(())
                        }
                        return BlockchainManager.instance.unbanUser(self.viewModel.community.communityId, commnityIssuer: self.viewModel.community.issuer ?? "", accountName: user.userId, reason: "")
                            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
                            .do(onError: { (error) in
                                self.showError(error)
                            }, onCompleted: {
                                self.showAlert(title: "proposal created".localized().uppercaseFirst, message: "proposal for user unbanning has been created".localized().uppercaseFirst)
                                var user = user
                                user.isUnBanProposalCreated = true
                                user.notifyChanged()
                            })
                            .andThen(.just(()))
                    }
                    cell.setUpUnBanAction(unBanAction)
                    cell.roundedCorner = []
                    
                    if indexPath.row == 0 {
                        cell.roundedCorner.insert([.topLeft, .topRight])
                    }
                    
                    if indexPath.row == self.viewModel.items.value.count - 1 {
                        cell.roundedCorner.insert([.bottomLeft, .bottomRight])
                    }
                    
                    return cell
                }
            }
        )
        
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .none)
        
        viewModel.items
            .filter { items in
                // disable binding to tableview when data is LeaderType
                // as leaders have already been binded to collectionView
                if items is [ResponseAPIContentGetLeader] &&
                    self.viewModel.segmentedItem.value == .all {
                    return false
                }
                return true
            }
            .map { items in
                items.compactMap {item -> CustomElementType? in
                    if let item = item as? ResponseAPIContentGetLeader {
                        return .leader(item)
                    }
                    if let item = item as? ResponseAPIContentGetProfile {
                        if self.viewModel.segmentedItem.value == .banned {
                            return .bannedUser(item)
                        }
                        return .subscriber(item)
                    }
                    return nil
                }
            }
            .map {[AnimatableSectionModel<String, CustomElementType>(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let leaderDataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, ResponseAPIContentGetLeader>>(
            configureCell: { (_, _, indexPath, leader) -> UICollectionViewCell in
                
                if indexPath.row >= self.viewModel.leadersVM.items.value.count - 2 {
                    self.viewModel.leadersVM.fetchNext()
                }
                
                let cell = self.headerView.leadersCollectionView.dequeueReusableCell(withReuseIdentifier: "LeaderFollowCollectionCell", for: indexPath) as! LeaderFollowCollectionCell
                cell.setUp(with: leader)
                cell.delegate = self
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
        tableView.rx.modelSelected(CustomElementType.self)
            .subscribe(onNext: { (element) in
                switch element {
                case .subscriber(let profile):
                    self.showProfileWithUserId(profile.userId)
                case .leader(let leader):
                    self.showProfileWithUserId(leader.userId)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        headerView.leadersCollectionView.rx.modelSelected(ResponseAPIContentGetLeader.self)
            .subscribe(onNext: { (leader) in
                self.showProfileWithUserId(leader.userId)
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
    
    // MARK: - Manage user
    func manageUser(_ user: ResponseAPIContentGetProfile) {
        showCMActionSheet(title: "manage user".localized().uppercaseFirst, titleFont: .boldSystemFont(ofSize: 17), titleAlignment: .left, actions: [
            .default(
                title: "do ban user".localized().uppercaseFirst,
                iconName: "report",
                tintColor: .appRedColor,
                handle: {
                    self.banUser(user)
                }
            )
        ])
    }
    
    func banUser(_ user: ResponseAPIContentGetProfile) {
        guard let issuer = viewModel.community.issuer else {return}
        present(CMBanUserBottomSheet(banningUser: user, communityId: viewModel.community.communityId, communityIssuer: issuer), animated: true, completion: nil)
    }
}
