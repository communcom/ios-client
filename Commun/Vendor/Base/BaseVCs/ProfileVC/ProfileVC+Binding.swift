//
//  ProfileVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
            .subscribe(onNext: {offsetY in
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
        
        _viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    self?._headerView.showLoader()
                case .finished:
                    self?._headerView.hideLoader()
                case .error(_):
                    guard let strongSelf = self else {return}
                    strongSelf._headerView.hideLoader()
                    let backButtonOriginTintColor = strongSelf.backButton.tintColor
                    strongSelf.backButton.tintColor = .black
                    strongSelf.view.showErrorView {
                        strongSelf.view.hideErrorView()
                        strongSelf.backButton.tintColor = backButtonOriginTintColor
                        strongSelf.reload()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // list loading state
        _viewModel.listLoadingState
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading(let isLoading):
                    if (isLoading) {
                        self?.handleListLoading()
                    }
                    else {
                        self?.tableView.tableFooterView = UIView()
                    }
                    break
                case .listEnded:
                    self?.tableView.tableFooterView = UIView()
                case .listEmpty:
                    self?.handleListEmpty()
                case .error(_):
                    guard let strongSelf = self else {return}
                    strongSelf.tableView.addListErrorFooterView(with: #selector(strongSelf.didTapTryAgain(gesture:)), on: strongSelf)
                    strongSelf.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindProfile() {
        _viewModel.profile
            .filter {$0 != nil}
            .map {$0!}
            .do(onNext: { (_) in
                self._headerView.selectedIndex.accept(0)
            })
            .subscribe(onNext: { [weak self] (item) in
                self?.setUp(profile: item)
            })
            .disposed(by: disposeBag)
    }
    
    func bindList() {
        // bind items
        _viewModel.items.skip(1)
            .bind(to: tableView.rx.items) {[weak self] table, index, element in
                if index == (self?.tableView.numberOfRows(inSection: 0) ?? 0) - 2 {
                    self?._viewModel.fetchNext()
                }
                
                return self?.createCell(for: table, index: index, element: element) ?? UITableViewCell()
            }
            .disposed(by: disposeBag)
        
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

        coverImageView.heightConstraint?.constant = coverHeight * coefficient
        coverImageView.widthConstraint?.constant = UIScreen.main.bounds.size.width * coefficient
        if coefficient > 1 {
//            coverImageView.transform = CGAffineTransform(scaleX: coefficient, y: coefficient)
        } else {
//            coverImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
//        self.coverImageView.layoutIf  Needed()
//        self.view.layoutIfNeeded()
    }
}
