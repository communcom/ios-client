//
//  UserProfilePageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension UserProfilePageVC: UICollectionViewDelegateFlowLayout {
    func bindSegmentedControl() {
        headerView.selectedIndex
            .map { index -> UserProfilePageViewModel.SegmentioItem in
                switch index {
                case 0:
                    return .posts
                case 1:
                    return .comments
                default:
                    fatalError("not found selected index")
                }
            }
            .bind(to: viewModel.segmentedItem)
            .disposed(by: disposeBag)
    }
    
    func bindCommunities() {
        // communities loading state
        viewModel.subscriptionsVM.state
            .subscribe(onNext: {[weak self] (state) in
                switch state {
                case .loading(let isLoading):
                    self?.communitiesCollectionView.heightConstraint?.constant = 187
                    if isLoading {
                        self?.communitiesCollectionView.showLoading()
                    }
                    else {
                        self?.communitiesCollectionView.hideLoading()
                    }
                case .listEnded:
                    self?.communitiesCollectionView.heightConstraint?.constant = 187
                    self?.communitiesCollectionView.hideLoading()
                case .listEmpty:
                    self?.communitiesCollectionView.heightConstraint?.constant = 0
                case .error(let error):
                    #warning("error state")
                    self?.communitiesCollectionView.hideLoading()
                }
            })
            .disposed(by: disposeBag)
        
        // communities
        viewModel.subscriptionsVM.items
            .skip(1)
            .map {$0.compactMap {$0.communityValue}}
            .bind(to: communitiesCollectionView.rx.items(cellIdentifier: "SubscriptionCommunityCell", cellType: SubscriptionCommunityCell.self)) { index, model, cell in
                cell.setUp(with: model)
            }
            .disposed(by: disposeBag)
        
        communitiesCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // select
        communitiesCollectionView.rx
            .modelSelected(ResponseAPIContentGetSubscriptionsCommunity.self)
            .subscribe(onNext: { (community) in
                self.showCommunityWithCommunityId(community.communityId)
            })
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 187)
    }
}

