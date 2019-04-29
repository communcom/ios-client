//
//  FeedPageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 29/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension FeedPageVC {
    func bindUI() {
        // segmentioView
        segmentioView.valueDidChange = {_, index in
            self.viewModel.feedTypeMode.accept(index == 0 ? .community : .byUser)
            
            // if feed is community then sort by popular
            if index == 0 {
                self.viewModel.feedType.accept(.popular)
            }
            
            // if feed is my feed, then sort by time
            if index == 1 {
                self.viewModel.feedType.accept(.time)
            }
        }
        
        // items
        viewModel.items
            .bind { (list) in
                self.makeCells()
            }
            .disposed(by: disposeBag)
    }
}
