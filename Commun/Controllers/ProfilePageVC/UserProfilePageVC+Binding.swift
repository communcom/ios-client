//
//  UserProfilePageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
        (viewModel as! UserProfilePageViewModel).profile
            .filter {$0?.highlightCommunities != nil}
            .map {$0!.highlightCommunities}
            .map {$0.map {ResponseAPIContentGetSubscriptionsCommunity(community: $0)}}
            .bind(to: communitiesCollectionView.rx.items(cellIdentifier: "SubscriptionCommunityCell", cellType: SubscriptionCommunityCell.self)) { index, model, cell in
                cell.setUp(with: model)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
    }
    
    func forwardDelegate() {
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
    
    func bindProfileBlocked() {
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                guard blockedProfile.userId == self.viewModel.profile.value?.userId else {return}
                self.back()
            })
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 187)
    }
}

