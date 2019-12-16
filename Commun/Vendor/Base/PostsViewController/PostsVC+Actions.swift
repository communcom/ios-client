//
//  PostsVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostsViewController {
    @objc func toggleFeedType() {
        guard let viewModel = viewModel as? PostsViewModel else {return}
        if viewModel.filter.value.feedTypeMode == .subscriptions {
            viewModel.changeFilter(feedTypeMode: .new)
        } else {
            viewModel.changeFilter(feedTypeMode: .subscriptions, feedType: .time)
        }
    }
    
    func openFilterVC() {
        guard let viewModel = viewModel as? PostsViewModel else {return}
        // Create FiltersVC
        let vc = PostsFilterVC(filter: viewModel.filter.value)
        
        vc.completion = { filter in
            viewModel.filter.accept(filter)
        }
        
        let nc = BaseNavigationController(rootViewController: vc)
        nc.transitioningDelegate = vc
        nc.modalPresentationStyle = .custom
        
        present(nc, animated: true, completion: nil)
    }
}
