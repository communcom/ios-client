//
//  NonAuthPostEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 7/21/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthPostEditorVC: BasicEditorVC, NonAuthVCType {
    init() {
        super.init(chooseCommunityAfterLoading: false, parseDraftAfterLoading: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Methods
    override func setUp() {
        super.setUp()
        // disable adding article
        removeTool(.addArticle)
        
        self.viewModel.community.accept(ResponseAPIContentGetCommunity.myFeed)
    }
}
