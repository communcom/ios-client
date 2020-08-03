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

extension NonAuthPostEditorVC {
    override func chooseCommunityDidTouch() {
        showAlert(title: "choose community".localized().uppercaseFirst, message: "you must sign in to choose community to post in".localized().uppercaseFirst, buttonTitles: ["sign in".localized().uppercaseFirst, "cancel".localized().uppercaseFirst], highlightedButtonIndex: 0) { index in
            if index == 0 {
                self.showAuthVC()
            }
        }
    }
    
    override func send() {
        DispatchQueue(label: "archiving").async {
            self.saveDraft()
        }
        showAuthVC()
    }
}
