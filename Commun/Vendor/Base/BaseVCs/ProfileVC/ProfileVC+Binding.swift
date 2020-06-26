//
//  ProfileVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension ProfileVC {
    func bindControls() {
        // headerView parallax
            
        tableView.rx.contentOffset
            .map {$0.y}
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {offSetY in
                // return contentInset after updating tableView
                if let inset = self.originInsetBottom,
                    (UIScreen.main.bounds.height - self.tableView.contentSize.height + offSetY < inset)
                {
                    self.tableView.contentInset.bottom = inset
                }
                
                // headerView paralax effect
                self.updateHeaderView()
                
                let showNavBar = offSetY < -43
                if self.showNavigationBar == !showNavBar {return}
                self.showNavigationBar = !showNavBar
            })
            .disposed(by: disposeBag)
        
        tableView.rx.willBeginDragging
            .subscribe(onNext: { (_) in
                self.frozenContentOffsetForRowAnimation = nil
            })
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll
            .subscribe(onNext: { (_) in
                if let overrideOffset = self.frozenContentOffsetForRowAnimation, self.tableView.contentOffset != overrideOffset
                {
                    self.tableView.setContentOffset(overrideOffset, animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    self?._headerView.hideLoader()
                    self?._headerView.showLoader()
                case .finished:
                    self?._headerView.hideLoader()
                case .error(let error):
                    guard let strongSelf = self else {return}
                    strongSelf._headerView.hideLoader()
                    let backButtonOriginTintColor = strongSelf.navigationItem.leftBarButtonItem?.tintColor
                    strongSelf.navigationItem.leftBarButtonItem?.tintColor = .appBlackColor
                    strongSelf.view.showErrorView(title: "Error".localized(), subtitle: error.localizedDescription) {
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
