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
        }
        
        // items
        viewModel.items
            .bind { (list) in
                self.makeCells()
            }
            .disposed(by: disposeBag)
    }
}
