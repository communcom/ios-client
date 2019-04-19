//
//  ProfilePageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 19/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ProfilePageVC {
    func bindViewModel() {
        let profile = viewModel.profile.asDriver()
        
        // End refreshing
        profile.map {_ in false}
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)
        
        // Bind state
        let isProfileMissing = profile.map {$0 == nil}
        
        isProfileMissing
            .drive(tableView.rx.isHidden)
            .disposed(by: bag)
        
        isProfileMissing
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        // Got profile
        let nonNilProfile = profile.filter {$0 != nil}.map {$0!}
        
        nonNilProfile
            .drive(self.rx.profile)
            .disposed(by: bag)
        
        // Bind posts
        let posts = viewModel.items.skip(1)
            .filter({ (items) -> Bool in
                if let _ = items as? [ResponseAPIContentGetPost] {return true}
                return false
            })
            .map {$0 as! [ResponseAPIContentGetPost]}
        
        posts
            .bind(to: tableView.rx.items(
                cellIdentifier: "PostCardCell",
                cellType: PostCardCell.self)
            ) { index, model, cell in
                cell.delegate = self
                cell.post = model
                cell.setupFromPost(model)
                
                // fetchNext when reaching last 5 items
                if index >= self.tableView.numberOfRows() - 5 {
                    self.viewModel.fetchNext()
                }
            }
            .disposed(by: bag)
        
        // Bind comments
        #warning("for comments later")
    }
}
