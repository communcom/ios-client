//
//  FTUECommunitesVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

extension FTUECommunitiesVC: CommunityCellDelegate {
    typealias Section = AnimatableSectionModel<String, ResponseAPIContentGetCommunity>
    
    func bindControl() {
        let offsetY = communitiesCollectionView.rx
            .contentOffset
            .map {$0.y + self.communitiesCollectionView.contentInset.top}
            .share()
        
        offsetY
            .distinctUntilChanged()
            .subscribe(onNext: { offsetY in
                var constant = 112 - offsetY
                if constant < 0 {constant = 0}
                self.searchBarTopConstraint?.constant = constant
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    func bindCommunities() {
        // state
        viewModel.mergedState
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loading(let isLoading):
                    if isLoading && self?.viewModel.itemsCount == 0 {
                        self?.communitiesCollectionView.showLoading(offsetTop: 20)
                    } else {
                        self?.communitiesCollectionView.hideLoading()
                    }
                case .listEnded:
                    self?.communitiesCollectionView.hideLoading()
                case .listEmpty:
                    self?.communitiesCollectionView.hideLoading()
                case .error:
                    self?.communitiesCollectionView.hideLoading()
                    if self?.viewModel.items.value.count == 0 {
                        self?.view.showErrorView {
                            self?.view.hideErrorView()
                            self?.viewModel.reload()
                        }
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        // items
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<Section>(
            configureCell: { (_, collectionView, indexPath, model) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityCollectionCell", for: indexPath) as! FTUECommunityCell
                cell.setUp(with: model)
                cell.delegate = self
                
                if indexPath.row >= self.viewModel.items.value.count - 3 {
                    self.viewModel.fetchNext()
                }
                return cell
            },
            configureSupplementaryView: {(_, collectionView, kind, indexPath) -> UICollectionReusableView in
                if kind == UICollectionView.elementKindSectionHeader {
                    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: FTUECommunitiesHeaderView.self, for: indexPath)
                    return headerView
                }
                fatalError()
            }
        )
        
        viewModel.mergedItems
            .map { items -> [ResponseAPIContentGetCommunity] in
                var items = items
                for i in 0..<items.count {
                    if self.viewModel.chosenCommunities.value.contains(where: {$0.identity == items[i].identity})
                    {
                        items[i].isSubscribed = true
                    }
                }
                return items
            }
            .skip(1)
            .map {[Section(model: "", items: $0)]}
            .bind(to: communitiesCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // chosenCommunity
        viewModel.chosenCommunities
            .map {communities -> [ResponseAPIContentGetCommunity?] in
                var communities = communities as [ResponseAPIContentGetCommunity?]
                if communities.count < 3 {
                    var placeholders = [ResponseAPIContentGetCommunity?]()
                    for _ in 0..<(3-communities.count) {
                        placeholders.append(nil)
                    }
                    communities += placeholders
                }
                return Array(communities.prefix(3))
            }
            .bind(to: chosenCommunitiesCollectionView.rx.items(cellIdentifier: "FTUEChosenCommunityCell", cellType: FTUEChosenCommunityCell.self)) { _, model, cell in
                if let model = model {
                    cell.deleteButton.isHidden = false
                    cell.setUp(with: model)
                } else {
                    cell.avatarImageView.image = nil
                    cell.avatarImageView.percent = 0
                    cell.deleteButton.isHidden = true
                }
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        viewModel.chosenCommunities
            .map {$0.count(where: {$0.isBeingJoined == false}) >= 3}
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.chosenCommunities
            .map {chosenCommunities -> Bool in
                // if 3 or more communities was succesfully subscribed
                if chosenCommunities.count(where: {$0.isBeingJoined == false}) >= 3 {
                    return false
                }
                
                // if there are some communities are being subscribed
                return chosenCommunities.count(where: {$0.isBeingJoined == true}) > 0
            }
            .distinctUntilChanged()
            .subscribe(onNext: { (isLoading) in
                if isLoading {
                    self.nextButton.showLoading(cover: false, spinnerColor: UIColor.white.withAlphaComponent(0.7), size: 30, spinerLineWidth: 3)
                    self.nextButton.setImage(nil, for: .normal)
                } else {
                    self.nextButton.hideLoading()
                    self.nextButton.setImage(UIImage(named: self.nextButtonImageName), for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func observeCommunityFollowed() {
        ResponseAPIContentGetCommunity.observeItemChanged()
            .filter {$0.isSubscribed == true}
            .distinctUntilChanged {$0.identity == $1.identity}
            .subscribe(onNext: { [weak self] (community) in
                guard var chosenCommunities = self?.viewModel.chosenCommunities.value else {return}
                chosenCommunities.joinUnique([community])
                self?.viewModel.chosenCommunities.accept(chosenCommunities)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .filter {$0.isSubscribed == false}
            .distinctUntilChanged {$0.identity == $1.identity}
            .subscribe(onNext: { [weak self] (community) in
                guard var chosenCommunities = self?.viewModel.chosenCommunities.value else {return}
                chosenCommunities.removeAll(where: {$0.identity == community.identity})
                self?.viewModel.chosenCommunities.accept(chosenCommunities)
            })
            .disposed(by: disposeBag)
    }
}
