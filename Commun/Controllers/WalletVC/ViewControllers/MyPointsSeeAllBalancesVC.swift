//
//  MyPointsSeeAllBalancesVC.swift
//  Commun
//
//  Created by Chung Tran on 3/5/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class MyPointsSeeAllBalancesVC: SearchableBalancesVC {
    
    override func layoutSearchBar() {
        view.addSubview(searchContainerView)
        searchContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        searchContainerView.addSubview(searchBar)
        
        searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0))
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    
    override func setUpTableView() {
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: tableViewMargin, excludingEdge: .top)
        tableViewTopConstraint = tableView.autoPinEdge(.top, to: .bottom, of: searchContainerView)
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func bind() {
        super.bind()
        
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { (_) in
                self.showSearchBar(onNavigationBar: true)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.textDidEndEditing
            .subscribe(onNext: { (_) in
                self.showSearchBar(onNavigationBar: false)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { (_) in
                self.showSearchBar(onNavigationBar: false)
                self.searchBarDidCancelSearching()
            })
            .disposed(by: disposeBag)
    }
    
    private func showSearchBar(onNavigationBar: Bool) {
        if onNavigationBar {
            navigationItem.titleView = searchBar
            navigationItem.rightBarButtonItem = nil
            
            tableViewTopConstraint?.isActive = false
            
            searchContainerView.removeFromSuperview()
            tableViewTopConstraint = tableView.autoPinEdge(toSuperviewSafeArea: .top)
            
            resetNavigationBar()
        } else {
            navigationItem.titleView = nil
            setRightNavBarButton(with: self.closeButton)
            
            tableViewTopConstraint?.isActive = false
            layoutSearchBar()
            tableViewTopConstraint = tableView.autoPinEdge(.top, to: .bottom, of: searchContainerView)
            
            resetNavigationBar()
        }
    }
    
    private func resetNavigationBar() {
        let img = UIImage()
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = .appWhiteColor
        navigationController?.navigationBar.subviews.first?.backgroundColor = .appWhiteColor
    }
}
