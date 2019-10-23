//
//  CommentsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa

class CommentsViewModel: ListViewModel<ResponseAPIContentGetComment>, CommentsListController {
    var filter: BehaviorRelay<CommentsListFetcher.Filter>!
    
    convenience init(
        filter: CommentsListFetcher.Filter = CommentsListFetcher.Filter(type: .user))
    {
        let fetcher = CommentsListFetcher(filter: filter)
        self.init(fetcher: fetcher)
        self.filter = BehaviorRelay<CommentsListFetcher.Filter>(value: filter)
        
        defer {
            observeCommentChange()
        }
    }
}
