//
//  CommunityPageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
                self.back()
            })
            .disposed(by: disposeBag)
    }
    
    func bindCommunityManager() {
        let vm = (viewModel as! CommunityPageViewModel)
        
        vm.proposalsVM.items
            .filter {_ in vm.profile.value?.isLeader == true}
            .map {_ in vm.proposalsVM.proposalsCount}
            .map {"\($0)"}
            .bind(to: headerView.manageCommunityButtonsView.proposalsCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        vm.reportsVM.items
            .filter {_ in vm.profile.value?.isLeader == true}
            .map {_ in vm.reportsVM.reportsCount}
            .map {"\($0)"}
            .bind(to: headerView.manageCommunityButtonsView.reportsCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // manage view
        let manageCommunityButtonsView = self.headerView.manageCommunityButtonsView
        let originalColor = UIColor.appBlackColor
        vm.proposalsVM.state
            .filter {_ in vm.profile.value?.isLeader == true}
            .subscribe(onNext: { state in
                switch state {
                case .loading(true):
                    manageCommunityButtonsView.proposalsButton.showLoader()
                    manageCommunityButtonsView.proposalsCountLabel.textColor = originalColor
                case .loading(false), .listEnded, .listEmpty:
                    manageCommunityButtonsView.proposalsButton.hideLoader()
                    manageCommunityButtonsView.proposalsCountLabel.textColor = originalColor
                case .error:
                    manageCommunityButtonsView.proposalsButton.hideLoader()
                    manageCommunityButtonsView.proposalsCountLabel.textColor = .red
                    manageCommunityButtonsView.proposalsCountLabel.text = "error".localized().uppercaseFirst
                }
            })
            .disposed(by: disposeBag)
        
        vm.reportsVM.state
            .filter {_ in vm.profile.value?.isLeader == true}
            .subscribe(onNext: { state in
                switch state {
                case .loading(true):
                    manageCommunityButtonsView.reportsButton.showLoader()
                    manageCommunityButtonsView.reportsCountLabel.textColor = originalColor
                case .loading(false), .listEnded, .listEmpty:
                    manageCommunityButtonsView.reportsButton.hideLoader()
                    manageCommunityButtonsView.reportsCountLabel.textColor = originalColor
                case .error:
                    manageCommunityButtonsView.reportsButton.hideLoader()
                    manageCommunityButtonsView.reportsCountLabel.textColor = .red
                    manageCommunityButtonsView.reportsCountLabel.text = "error".localized().uppercaseFirst
                }
            })
            .disposed(by: disposeBag)
        
        let isLeader = vm.leadsVM.items.filter {!$0.isEmpty}.map {$0.filter {$0.inTop}}.map {$0.contains(where: {$0.userId == Config.currentUser?.id})}
            .asDriver(onErrorJustReturn: false)
        
        isLeader.map {!$0}
            .distinctUntilChanged()
            .drive(manageCommunityButtonsView.rx.isHidden)
            .disposed(by: disposeBag)
        
        isLeader.map {!$0}
            .distinctUntilChanged()
            .drive(manageCommunityBarButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
