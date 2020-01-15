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
            .skip(1)
            .map {$0.compactMap {$0.communityValue}}
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
        let label = (headerView as! MyProfileHeaderView).communValueLabel
        (viewModel as! MyProfilePageViewModel).balancesVM.state
            .subscribe(onNext: {(state) in
                label.textColor = .white
                label.text = "loading..."
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        label.showLoader()
                    } else {
                        label.hideLoader()
                    }
                case .listEnded:
                    label.hideLoader()
                case .listEmpty:
                    label.hideLoader()
                case .error:
                    label.hideLoader()
                    label.textColor = .red
                    label.text = "error".localized().uppercaseFirst + "!!!"
                }
            })
            .disposed(by: disposeBag)
        
        (viewModel as! MyProfilePageViewModel).balancesVM.items
            .map {$0.first(where: {$0.symbol == "CMN"})?.balanceValue.currencyValueFormatted}
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}
