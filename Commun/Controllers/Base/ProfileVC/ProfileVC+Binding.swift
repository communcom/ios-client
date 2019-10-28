//
//  ProfileVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ProfileVC {
    func bindControls() {
        // headerView parallax
        tableView.rx.contentOffset
            .map {$0.y}
            .subscribe(onNext: {offsetY in
                self.updateHeaderView()
            })
            .disposed(by: disposeBag)
        
        // scrolling
        tableView.rx.didScroll
            .map {_ in self.tableView.contentOffset.y < -43}
            .distinctUntilChanged()
            .subscribe(onNext: { showNavBar in
                self.showTitle(!showNavBar)
            })
            .disposed(by: disposeBag)
        
        #warning("retry button")
        //        let retryButton = UIButton(forAutoLayout: ())
        //        retryButton.setTitleColor(.gray, for: .normal)
        // bind community loading state
        _viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    self?.view.showLoading()
                case .finished:
                    self?.view.hideLoading()
                case .error(let error):
                    self?.showError(error)
                    self?.back()
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
            .do(onNext: { [weak self] newItems in
                // handle empty state
                if self?._viewModel.listLoadingState.value == .listEnded,
                    newItems.count == 0
                {
                    self?.handleListEmpty()
                }
            })
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
        if offset < -coverHeight {
            let originHeight = coverHeight
            
            let scale = -offset / (originHeight  - 24)
            coverImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            coverImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        coverImageView.layoutIfNeeded()
    }
}
