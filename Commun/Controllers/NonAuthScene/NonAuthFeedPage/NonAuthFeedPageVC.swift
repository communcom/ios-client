//
//  NonAuthFeedPage.swift
//  Commun
//
//  Created by Chung Tran on 7/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthFeedPageVC: FeedPageVC, NonAuthVCType {
    override init() {
        let vm = NonAuthFeedPageVM()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func changeFeedTypeButtonDidTouch(_ sender: Any) {
        showAuthVC()
    }
    
    override func saveFilter(filter: PostsListFetcher.Filter) {
        // do nothing
    }
    
    override func openEditor(completion: ((BasicEditorVC) -> Void)? = nil) {
        showAuthVC()
    }
    
    override func modelSelected(_ post: ResponseAPIContentGetPost) {
        let postPageVC = NonAuthPostPageVC(post: post)
        show(postPageVC, sender: nil)
    }
}
