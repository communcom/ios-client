//
//  CommunityPageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension CommunityPageVC {
    func bindSelectedIndex() {
        headerView.selectedIndex
            .map { index -> CommunityPageViewModel.SegmentioItem in
                switch index {
                case 0:
                    return .posts
                case 1:
                    return .leads
                case 2:
                    return .about
                case 3:
                    return .rules
                default:
                    fatalError("not found selected index")
                }
            }
            .bind(to: (viewModel as! CommunityPageViewModel).segmentedItem)
            .disposed(by: disposeBag)
    }
    
    func bindProfileBlocked() {
        ResponseAPIContentGetCommunity.observeEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                guard blockedProfile.communityId == self.viewModel.profile.value?.communityId else {return}
                self.leftButtonTapped()
            })
            .disposed(by: disposeBag)
    }
}
