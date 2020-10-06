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
                title: "ban user".localized().uppercaseFirst,
                iconName: "report",
                tintColor: .appRedColor,
                handle: {
                    self.banUser(user)
                }
            )
        ])
    }
    
    func banUser(_ user: ResponseAPIContentGetProfile) {
        present(CMBanUserBottomSheet(banningUser: user), animated: true, completion: nil)
    }
}

class CMBanUserBottomSheet: CMBottomSheet {
    let banningUser: ResponseAPIContentGetProfile
    
    lazy var stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
    
    init(banningUser: ResponseAPIContentGetProfile) {
        self.banningUser = banningUser
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        let headerLabel = UILabel.with(text: "ban user".localized().uppercaseFirst, textSize: 15, weight: .bold)
        headerStackView.insertArrangedSubview(headerLabel, at: 0)
        
        // set up action
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10))
        
        let label = UILabel.with(text: "are you sure want to ban this user?".localized().uppercaseFirst, numberOfLines: 0)
        
        let userWrapper: UIView = {
            let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
            let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges()
            
            let cell = SubscribersCell(forAutoLayout: ())
            cell.configureToUseAsNormalView()
            cell.setUp(with: banningUser)
            cell.actionButton.isHidden = true
            
            let spacer = UIView.spacer(height: 1, backgroundColor: .appLightGrayColor)
            
            let reasonButton: UIView = {
                let view = UIView(forAutoLayout: ())
                let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
                view.addSubview(stackView)
                stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
                
                stackView.addArrangedSubview(UILabel.with(text: "choose your ban reason".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .appMainColor, numberOfLines: 0))
                let arrow = UIButton.nextArrow()
                arrow.isUserInteractionEnabled = false
                stackView.addArrangedSubview(arrow)
                return view.onTap(self, action: #selector(selectReasonButtonDidTouch))
            }()
            
            stackView.addArrangedSubviews([cell, spacer, reasonButton])
            
            return view
        }()
        
        let yesButton: UILabel = {
            let yesButton = UILabel.with(text: "yes, propose to ban".localized().uppercaseFirst, textSize: 15, weight: .medium, textColor: .appRedColor, numberOfLines: 0, textAlignment: .center)
            yesButton.backgroundColor = .white
            yesButton.cornerRadius = 10
            yesButton.autoSetDimension(.height, toSize: 50)
            return yesButton.onTap(self, action: #selector(yesButtonDidTouch))
        }()
        
        let noButton: UILabel = {
            let noButton = UILabel.with(text: "no, keep user".localized().uppercaseFirst, textSize: 15, weight: .medium, numberOfLines: 0, textAlignment: .center)
            noButton.backgroundColor = .white
            noButton.cornerRadius = 10
            noButton.autoSetDimension(.height, toSize: 50)
            return noButton.onTap(self, action: #selector(noButtonDidTouch))
        }()
        
        stackView.addArrangedSubviews([label, userWrapper, yesButton, noButton])
        stackView.setCustomSpacing(16, after: label)
        stackView.setCustomSpacing(30, after: userWrapper)
        stackView.setCustomSpacing(10, after: yesButton)
    }
    
    @objc func selectReasonButtonDidTouch() {
        
    }
    
    @objc func yesButtonDidTouch() {
        
    }
    
    @objc func noButtonDidTouch() {
        back()
    }
}
