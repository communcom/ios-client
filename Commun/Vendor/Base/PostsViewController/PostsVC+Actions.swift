//
//  PostsVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostsViewController {
    @objc func toggleFeedType() {
        guard let viewModel = viewModel as? PostsViewModel else {return}
        if viewModel.filter.value.feedTypeMode == .subscriptions {
            viewModel.changeFilter(feedTypeMode: .new)
        }
        
        else {
            viewModel.changeFilter(feedTypeMode: .subscriptions, feedType: .timeDesc)
        }
    }
    
    func openFilterVC() {
        guard let viewModel = viewModel as? PostsViewModel else {return}
        // Create FiltersVC
        let vc = controllerContainer.resolve(FeedPageFiltersVC.self)!
        vc.filter.accept(viewModel.filter.value)
        vc.completion = { filter in
            viewModel.filter.accept(filter)
        }
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        
        present(vc, animated: true, completion: nil)
    }
}
