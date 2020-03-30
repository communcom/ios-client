//
//  UserProfilePageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

extension UserProfilePageVC: UICollectionViewDelegateFlowLayout, CommunityCellDelegate {
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
            .bind(to: (viewModel as! UserProfilePageViewModel).segmentedItem)
            .disposed(by: disposeBag)
    }
    
    @objc func bindCommunities() {
        let highlightCommunities = (viewModel as! UserProfilePageViewModel).highlightCommunities
        
        highlightCommunities
            .skip(1)
            .bind(to: communitiesCollectionView.rx.items(cellIdentifier: "CommunityCollectionCell", cellType: CommunityCollectionCell.self)) { _, model, cell in
                cell.setUp(with: model)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .subscribe(onNext: { (community) in
                var newItems = highlightCommunities.value
                guard let index = newItems.firstIndex(where: {$0.identity == community.identity}) else {return}
                guard let newUpdatedItem = newItems[index].newUpdatedItem(from: community) else {return}
                newItems[index] = newUpdatedItem
                highlightCommunities.accept(newItems)
            })
            .disposed(by: disposeBag)
    }
    
    func forwardDelegate() {
        communitiesCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // select
        communitiesCollectionView.rx
            .modelSelected(ResponseAPIContentGetCommunity.self)
            .subscribe(onNext: { (community) in
                self.showCommunityWithCommunityId(community.communityId)
            })
            .disposed(by: disposeBag)
        
        // tableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 187)
    }
}
