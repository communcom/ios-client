//
//  MyProfilePageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension MyProfilePageVC {
    override func bindCommunities() {
        // communities loading state
        (viewModel as! MyProfilePageViewModel).subscriptionsVM.state
            .subscribe(onNext: {[weak self] (state) in
                switch state {
                case .loading(let isLoading):
                    self?.headerView.isCommunitiesHidden = false
                    if isLoading && (self?.viewModel as? MyProfilePageViewModel)?.subscriptionsVM.items.value.count == 0 {
                        self?.communitiesCollectionView.showLoading()
                    } else {
                        self?.communitiesCollectionView.hideLoading()
                    }
                case .listEnded:
                    self?.headerView.isCommunitiesHidden = false
                    self?.communitiesCollectionView.hideLoading()
                case .listEmpty:
                    self?.communitiesCollectionView.hideLoading()
                    self?.headerView.isCommunitiesHidden = true
                case .error:
                    //TODO: error state
                    self?.communitiesCollectionView.hideLoading()
                    self?.headerView.isCommunitiesHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        // communities
        (viewModel as! MyProfilePageViewModel).subscriptionsVM.items
            .map {$0.compactMap {$0.communityValue}}
            .map {$0.filter {$0.isBeingJoined == true || $0.isSubscribed == true}}
            .bind(to: communitiesCollectionView.rx.items(cellIdentifier: "CommunityCollectionCell", cellType: CommunityCollectionCell.self)) { index, model, cell in
                cell.setUp(with: model)
                cell.delegate = self
                
                if index >= (self.viewModel as! MyProfilePageViewModel).subscriptionsVM.items.value.count - 3 {
                    (self.viewModel as! MyProfilePageViewModel).subscriptionsVM.fetchNext()
                }
        }
        .disposed(by: disposeBag)
    }
    
    func bindBalances() {
        let walletView = (headerView as! MyProfileHeaderView).walletView
        
        (viewModel as! MyProfilePageViewModel).balancesVM.state
            .subscribe(onNext: {[weak self] (state) in
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        (self?.headerView as? MyProfileHeaderView)?.setUpWalletView()
                        walletView.showLoading(cover: false, spinnerColor: .appWhiteColor, size: 20, centerYOffset: 10)
                    } else {
                        walletView.hideLoading()
                    }
                case .listEnded:
                    walletView.hideLoading()
                case .listEmpty:
                    walletView.hideLoading()
                case .error:
                    walletView.hideLoading()
                    (self?.headerView as? MyProfileHeaderView)?.setUpWalletView(withError: true)
                }
            })
            .disposed(by: disposeBag)
        
        (viewModel as! MyProfilePageViewModel).balancesVM.items
            .subscribe(onNext: { (balances) in
                self.setUpEquityValue(balances: balances)
            })
            .disposed(by: disposeBag)
        
        UserDefaults.standard.rx
            .observe(Bool.self, Config.currentEquityValueIsShowingCMN)
            .subscribe(onNext: { (_) in
                let balances = (self.viewModel as! MyProfilePageViewModel).balancesVM.items.value
                self.setUpEquityValue(balances: balances)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpEquityValue(balances: [ResponseAPIWalletGetBalance]) {
        (headerView as! MyProfileHeaderView).walletView.setUp(balances: balances)
    }
}
