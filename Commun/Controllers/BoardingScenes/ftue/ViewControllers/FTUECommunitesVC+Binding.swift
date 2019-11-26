//
//  FTUECommunitesVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension FTUECommunitiesVC: UICollectionViewDelegateFlowLayout {
    func bindCommunities() {
        // state
        viewModel.state
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        self?.view.showLoading()
                    }
                    else {
                        self?.view.hideLoading()
                    }
                case .listEnded:
                    self?.view.hideLoading()
                case .listEmpty:
                    self?.view.hideLoading()
                case .error(let error):
                    #warning("error state")
                    self?.view.hideLoading()
                }
                
            })
            .disposed(by: disposeBag)
        
        // items
        viewModel.items
            .skip(1)
            .map {$0.map {ResponseAPIContentGetSubscriptionsCommunity(community: $0)}}
            .bind(to: communitiesCollectionView.rx.items(cellIdentifier: "SubscriptionCommunityCell", cellType: SubscriptionCommunityCell.self)) { index, model, cell in
                cell.setUp(with: model)
            }
            .disposed(by: disposeBag)
        
        communitiesCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.width - collectionView.contentInset.left - collectionView.contentInset.right
        let horizontalSpacing: CGFloat = 16
        let itemWidth = (width - horizontalSpacing) / 2
        let height = itemWidth * 171 / 165
        return CGSize(width: itemWidth, height: height + 10)
    }
}
