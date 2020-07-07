//
//  NonAuthFeedPage.swift
//  Commun
//
//  Created by Chung Tran on 7/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthFeedPageVC: FeedPageVC {
    override init() {
        let vm = NonAuthFeedPageVM()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        floatView.changeFeedTypeButton.isHidden = true
    }
    
    override func saveFilter(filter: PostsListFetcher.Filter) {
        // do nothing
    }
}
