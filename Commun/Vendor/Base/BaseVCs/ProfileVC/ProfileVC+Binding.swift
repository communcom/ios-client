//
//  ProfileVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import ESPullToRefresh

extension ProfileVC {
    func bindControls() {
        // headerView parallax
        let offSetY = tableView.rx.contentOffset
            .map {$0.y}
            .share()
            
        offSetY
            .subscribe(onNext: {_ in
                self.updateHeaderView()
            })
            .disposed(by: disposeBag)
        
        // hide pull to refresh
        offSetY
            .map {$0 < -179}
            .subscribe(onNext: { (show) in
                self.tableView.subviews.first(where: {$0 is ESRefreshHeaderView})?.alpha = show ? 1 : 0
            })
            .disposed(by: disposeBag)
        
        // scrolling
        offSetY
            .map {$0 < -43}
            .subscribe(onNext: { showNavBar in
                self.showTitle(!showNavBar)
            })
            .disposed(by: disposeBag)
        
        viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    self?._headerView.showLoader()
                case .finished:
                    self?._headerView.hideLoader()
                case .error:
                    guard let strongSelf = self else {return}
                    strongSelf._headerView.hideLoader()
                    let backButtonOriginTintColor = strongSelf.navigationItem.leftBarButtonItem?.tintColor
                    strongSelf.navigationItem.leftBarButtonItem?.tintColor = .black
                    strongSelf.view.showErrorView {
                        strongSelf.view.hideErrorView()
                        strongSelf.navigationItem.leftBarButtonItem?.tintColor = backButtonOriginTintColor
                        strongSelf.reload()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // list loading state
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
                    guard let strongSelf = self else {return}
                    strongSelf.tableView.addListErrorFooterView(with: #selector(strongSelf.didTapTryAgain(gesture:)), on: strongSelf)
                    strongSelf.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        // load more
        tableView.addLoadMoreAction { [weak self] in
            self?.viewModel.fetchNext()
        }
            .disposed(by: disposeBag)
    }
    
    func bindList() {
        // bind items
        bindItems()
        
        // OnItemSelected
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath in
                self?.cellSelected(indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateHeaderView() {
        let offset = tableView.contentOffset.y
        let y = coverHeight - (offset + coverHeight)
        var coefficient: CGFloat = y / coverVisibleHeight

        if coefficient < 1 {
            coefficient = 1
        }

        coverImageWidthConstraint.constant = UIScreen.main.bounds.size.width * coefficient
        coverImageHeightConstraint.constant = coverHeight * coefficient
    }
}
